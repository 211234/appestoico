import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import 'local_storage_service.dart';
import '../offline_service.dart';
import '../connectivity_service.dart';
import '../token_expiration_handler.dart';

/// Servicio para gestión de quiz
class QuizService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Mapear valores de daily challenges del frontend al backend
  // Backend acepta: 'meditacion_matutina', 'meditación', 'meditacion', 'reflexion_nocturna', 
  // 'reflexión', 'reflexion', 'diario_estoico', 'diario', 'visualizacion_negativa', 
  // 'estres', 'ansiedad', 'ira', 'frustracion', 'tristeza', 'miedo', 'procrastinacion', 
  // 'falta_de_enfoque', 'relaciones', 'presion_laboral', 'ejercicio_fisico' o 'gratitud'
  static String _mapDailyChallengeToBackend(String frontendValue) {
    final Map<String, String> mapping = {
      'meditacion_matutina': 'meditacion_matutina', // ✅ Válido
      'reflexion_nocturna': 'reflexion_nocturna', // ✅ Válido
      'ejercicio_fisico': 'ejercicio_fisico', // ✅ Válido
      'lectura_estoica': 'diario_estoico', // Mapear a diario_estoico
      'acto_de_bondad': 'gratitud', // Mapear a gratitud
      'tiempo_en_silencio': 'meditacion', // Mapear a meditacion
      'practica_de_gratitud': 'gratitud', // ✅ Válido
      'control_emocional': 'ansiedad', // Mapear control emocional a ansiedad (manejo de emociones)
    };
    return mapping[frontendValue] ?? frontendValue;
  }

  // Mapear valores de stoic paths del frontend al backend
  // Backend acepta: 'Paz Interior', 'paz interior', 'paz_interior', 'Autocontrol', 'autocontrol',
  // 'Sabiduría', 'sabiduría', 'sabiduria', 'Resiliencia', 'resiliencia', 'Gratitud', 'gratitud',
  // 'Justicia', 'justicia', 'Coraje', 'coraje', 'Templanza', 'templanza' o 'virtud'
  static String _mapStoicPathToBackend(String frontendValue) {
    final Map<String, String> mapping = {
      'paz_interior': 'paz_interior', // ✅ Válido
      'autocontrol': 'autocontrol', // ✅ Válido
      'sabiduria': 'sabiduria', // ✅ Válido
      'resiliencia': 'resiliencia', // ✅ Válido
      'proposito': 'virtud', // Mapear propósito a virtud
      'equilibrio': 'templanza', // Mapear equilibrio a templanza
    };
    return mapping[frontendValue] ?? frontendValue;
  }

  // Enviar Quiz completo
  static Future<Map<String, dynamic>> submitQuiz({
    required String ageRange,
    required String gender,
    required String country,
    required String religiousBelief,
    required String spiritualPracticeLevel,
    required String spiritualPracticeFrequency,
    required List<String> dailyChallenges,
    required List<String> stoicPaths,
    String? stoicLevel,
  }) async {
    try {
      final userData = await LocalStorageService.getUserData();
      final token = userData['token'];

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'No se encontró el token de autenticación',
        };
      }

      // Mapear valores antes de enviar
      final mappedDailyChallenges = dailyChallenges.map((challenge) {
        return _mapDailyChallengeToBackend(challenge);
      }).toList();
      
      final mappedStoicPaths = stoicPaths.map((path) {
        return _mapStoicPathToBackend(path);
      }).toList();

      final requestBody = {
        'age_range': ageRange,
        'gender': gender,
        'country': country,
        'religious_belief': religiousBelief,
        'spiritual_practice_level': spiritualPracticeLevel,
        'spiritual_practice_frequency': spiritualPracticeFrequency,
        'daily_challenges': mappedDailyChallenges,
        'stoic_paths': mappedStoicPaths,
        'stoic_level': stoicLevel,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/quiz/submit'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'El servidor no respondió correctamente',
        };
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return {'success': false, 'message': 'Error al procesar la respuesta'};
      }

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else if (response.statusCode == 401) {
        // Token expirado
        await TokenExpirationHandler.handleTokenExpiration(401);
        return {
          'success': false,
          'message':
              'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
          'tokenExpired': true,
        };
      } else {
        // Si hay error de validación, mostrar mensaje más claro
        String errorMessage = data['message'] ?? 'Error al enviar el quiz';
        if (errorMessage.contains('validation errors') || errorMessage.contains('Input should be')) {
          errorMessage = 'Error de validación: Los valores enviados no coinciden con los esperados por el servidor. Por favor, completa el quiz nuevamente.';
        }
        return {
          'success': false,
          'message': errorMessage,
          'responseBody': data,
        };
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        return {
          'success': false,
          'message': 'Error de conexión:\nEl servidor no está disponible',
        };
      }
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener datos del quiz completado
  static Future<Map<String, dynamic>> getQuizData() async {
    try {
      // Intentar cargar desde cache si no hay conexión
      if (!ConnectivityService.isOnline) {
        final cachedQuiz = await OfflineService.getQuizData();
        if (cachedQuiz != null) {
          return {'success': true, 'data': cachedQuiz, 'offline': true};
        }
        return {
          'success': false,
          'message': 'Sin conexión y no hay datos del quiz en cache',
        };
      }

      final userData = await LocalStorageService.getUserData();
      final token = userData['token'];

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'No se encontró el token de autenticación',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/quiz/my-quiz'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'El servidor no respondió correctamente',
        };
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Error al procesar la respuesta del servidor',
        };
      }

      if (response.statusCode == 200 && data['success'] == true) {
        await OfflineService.saveQuizData(data['data']);
        return {'success': true, 'data': data['data']};
      } else if (response.statusCode == 401) {
        // Token expirado
        await TokenExpirationHandler.handleTokenExpiration(401);
        return {
          'success': false,
          'message':
              'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
          'tokenExpired': true,
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'No se pudieron obtener los datos del quiz',
        };
      }
    } catch (e) {
      // Si falla la conexión, intentar cargar desde cache
      final cachedQuiz = await OfflineService.getQuizData();
      if (cachedQuiz != null) {
        return {'success': true, 'data': cachedQuiz, 'offline': true};
      }

      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        return {
          'success': false,
          'message': 'Error de conexión:\nEl servidor no está disponible',
        };
      }
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
