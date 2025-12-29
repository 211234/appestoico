import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';
import '../offline_service.dart';
import '../connectivity_service.dart';
import '../../models/reflection.dart';

/// Servicio para gestión del diario (reflexiones)
class DiaryService {
  static const String baseUrl = 'https://web.estoico.app/api';

  // Obtener todas las reflexiones del usuario
  static Future<Map<String, dynamic>> getAllReflections() async {
    try {
      final token = await LocalStorageService.getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'No se encontró el token de autenticación',
        };
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/diario/all'),
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
        return {'success': false, 'message': 'Error al procesar la respuesta'};
      }

      if (response.statusCode == 200) {
        if (data['data'] != null && data['data'] is List) {
          final List<dynamic> reflectionsJson = data['data'];
          final List<Reflection> reflections = reflectionsJson
              .map((json) => Reflection.fromJson(json))
              .toList();
          return {'success': true, 'data': reflections};
        } else {
          return {'success': true, 'data': []};
        }
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener reflexiones',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener reflexión de una fecha específica
  static Future<Map<String, dynamic>> getReflectionByDate(String date) async {
    try {
      final token = await LocalStorageService.getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'No se encontró el token de autenticación',
        };
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/diario?date=$date'),
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
        return {'success': false, 'message': 'Error al procesar la respuesta'};
      }

      if (response.statusCode == 200) {
        if (data['data'] != null) {
          return {'success': true, 'data': Reflection.fromJson(data['data'])};
        } else {
          return {'success': true, 'data': null};
        }
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener reflexión',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Crear/actualizar reflexión matutina
  static Future<Map<String, dynamic>> saveMorningReflection({
    required String date,
    required String morningText,
  }) async {
    try {
      final token = await LocalStorageService.getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'No se encontró el token de autenticación',
        };
      }

      // Si no hay conexión, guardar en cola offline
      if (!ConnectivityService.isOnline) {
        await OfflineService.savePendingReflection({
          'type': 'morning',
          'date': date,
          'text': morningText,
          'timestamp': DateTime.now().toIso8601String(),
        });
        return {
          'success': true,
          'message':
              'Reflexión guardada. Se sincronizará cuando haya conexión.',
          'offline': true,
        };
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/diario'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': 'true',
            },
            body: jsonEncode({'text': morningText}),
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al guardar reflexión',
        };
      }
    } catch (e) {
      // Si falla la conexión, guardar offline
      await OfflineService.savePendingReflection({
        'type': 'morning',
        'date': date,
        'text': morningText,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return {
        'success': true,
        'message':
            'Reflexión guardada offline. Se sincronizará automáticamente.',
        'offline': true,
      };
    }
  }

  // Eliminar reflexión
  static Future<Map<String, dynamic>> deleteReflection(String id) async {
    try {
      final token = await LocalStorageService.getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'No se encontró el token de autenticación',
        };
      }

      final response = await http
          .delete(
            Uri.parse('$baseUrl/diario/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': 'true',
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
        return {'success': false, 'message': 'Error al procesar la respuesta'};
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': data['message'] ?? 'Reflexión eliminada correctamente',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al eliminar reflexión',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Actualizar reflexión
  static Future<Map<String, dynamic>> updateReflection({
    required String id,
    String? morningText,
    String? eveningText,
  }) async {
    try {
      final token = await LocalStorageService.getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'No se encontró el token de autenticación',
        };
      }

      final textToUpdate = morningText ?? eveningText;
      if (textToUpdate == null) {
        return {
          'success': false,
          'message': 'Debe proporcionar un texto para actualizar',
        };
      }

      // Si no hay conexión, guardar en cola offline
      if (!ConnectivityService.isOnline) {
        await OfflineService.savePendingReflection({
          'id': id,
          'type': 'update',
          'date': DateTime.now().toIso8601String().split('T')[0],
          'text': textToUpdate,
          'timestamp': DateTime.now().toIso8601String(),
        });
        return {
          'success': true,
          'message':
              'Cambios guardados. Se sincronizarán cuando haya conexión.',
          'offline': true,
        };
      }

      final response = await http
          .patch(
            Uri.parse('$baseUrl/diario/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': 'true',
            },
            body: jsonEncode({'text': textToUpdate}),
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar reflexión',
        };
      }
    } catch (e) {
      // Si falla la conexión, guardar offline
      final textToUpdate = morningText ?? eveningText;
      if (textToUpdate != null) {
        await OfflineService.savePendingReflection({
          'id': id,
          'type': 'update',
          'date': DateTime.now().toIso8601String().split('T')[0],
          'text': textToUpdate,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
      return {
        'success': true,
        'message':
            'Cambios guardados offline. Se sincronizarán automáticamente.',
        'offline': true,
      };
    }
  }

  // Método de compatibilidad
  static Future<void> saveReflection({
    required String date,
    required String eveningText,
  }) async {}
}
