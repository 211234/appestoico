import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import 'local_storage_service.dart';
import '../offline_service.dart';
import '../connectivity_service.dart';
import '../token_expiration_handler.dart';

/// Servicio para gestión del perfil del usuario
class UserService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Obtener perfil del usuario desde el servidor
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      // Intentar cargar desde cache si no hay conexión
      if (!ConnectivityService.isOnline) {
        final cachedProfile = await OfflineService.getUserProfile();
        if (cachedProfile != null) {
          return {'success': true, 'data': cachedProfile, 'offline': true};
        }
        return {
          'success': false,
          'message': 'Sin conexión y no hay datos en cache',
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
        Uri.parse('$baseUrl/users/me'),
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
        return {'success': false, 'message': 'Error al procesar la respuesta'};
      }

      if (response.statusCode == 200) {
        // Guardar suscripción si está presente en la respuesta
        if (data['subscription'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('subscription', jsonEncode(data['subscription']));
        }
        
        if (data['success'] == true && data['data'] != null) {
          final profileData = data['data']['user'] ?? data['data'];
          await OfflineService.saveUserProfile(profileData);

          // Incluir suscripción en la respuesta si está disponible
          final result = <String, dynamic>{};
          if (data['data']['user'] != null) {
            result['success'] = true;
            result['data'] = data['data']['user'];
          } else {
            result['success'] = true;
            result['data'] = data['data'];
          }
          
          // Agregar suscripción a la respuesta si existe
          if (data['subscription'] != null) {
            result['subscription'] = data['subscription'];
          }
          
          return result;
        } else if (data['nombre'] != null || data['email'] != null) {
          final result = {'success': true, 'data': data};
          if (data['subscription'] != null) {
            result['subscription'] = data['subscription'];
          }
          return result;
        } else {
          return {
            'success': false,
            'message': 'El perfil está vacío. Por favor completa el quiz.',
          };
        }
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
          'message': data['message'] ?? 'Error al obtener el perfil',
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

  // Actualizar información básica del quiz
  static Future<Map<String, dynamic>> updateQuizInfo({
    required String ageRange,
    required String gender,
    required String country,
    required String religiousBelief,
  }) async {
    try {
      final token = await LocalStorageService.getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'No se encontró el token de autenticación',
        };
      }

      final response = await http
          .patch(
            Uri.parse('$baseUrl/users/quiz-info'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'age_range': ageRange,
              'gender': gender,
              'country': country,
              'religious_belief': religiousBelief,
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

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Información actualizada correctamente',
          'data': data['data'],
        };
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
          'message': data['message'] ?? 'Error al actualizar información',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Actualizar perfil completo
  static Future<Map<String, dynamic>> updateProfile({
    required String ageRange,
    required String gender,
    required String country,
    required String religiousBelief,
    required String spiritualPracticeLevel,
    required String spiritualPracticeFrequency,
    required List<String> stoicPaths,
    String? stoicLevel,
  }) async {
    try {
      final token = await LocalStorageService.getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'No se encontró el token de autenticación',
        };
      }

      final response = await http
          .patch(
            Uri.parse('$baseUrl/users/quiz-info'),
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
        print('❌ Error parsing JSON in updateProfile: $e');
        return {
          'success': false,
          'message':
              'Error al procesar la respuesta. Status: ${response.statusCode}',
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Perfil actualizado correctamente',
          'data': data['data'],
        };
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
        print('❌ Error del servidor: ${response.statusCode}');
        print('❌ Mensaje de error: ${data['message']}');
        print('❌ Errores: ${data['errors']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar perfil',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
