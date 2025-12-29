import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';
import '../offline_service.dart';
import '../connectivity_service.dart';

/// Servicio para gestión de quiz
class QuizService {
  static const String baseUrl = 'https://web.estoico.app/api';

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

      final response = await http
          .post(
            Uri.parse('$baseUrl/quiz/submit'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'age_range': ageRange,
              'gender': gender,
              'country': country,
              'religious_belief': religiousBelief,
              'spiritual_practice_level': spiritualPracticeLevel,
              'spiritual_practice_frequency': spiritualPracticeFrequency,
              'daily_challenges': dailyChallenges,
              'stoic_paths': stoicPaths,
              'stoic_level': stoicLevel,
            }),
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
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al enviar el quiz',
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

      final response = await http
          .get(
            Uri.parse('$baseUrl/quiz/my-quiz'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
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
        return {
          'success': false,
          'message': 'Error al procesar la respuesta del servidor',
        };
      }

      if (response.statusCode == 200 && data['success'] == true) {
        await OfflineService.saveQuizData(data['data']);
        return {'success': true, 'data': data['data']};
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
