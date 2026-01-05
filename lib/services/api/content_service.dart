import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import 'local_storage_service.dart';
import '../offline_service.dart';
import '../connectivity_service.dart';
import '../token_expiration_handler.dart';

/// Servicio para contenido general (frases del día, emblemas, etc)
class ContentService {
  static String get baseUrl => AppConfig.apiBaseUrl;
  static String get emblemasUrl => AppConfig.emblemasUrl;

  // Obtener frase del día
  static Future<Map<String, dynamic>> getDailyQuote() async {
    try {
      // Intentar cargar desde cache si no hay conexión
      if (!ConnectivityService.isOnline) {
        final cachedQuote = await OfflineService.getDailyQuote();
        if (cachedQuote != null) {
          return {'success': true, 'data': cachedQuote, 'offline': true};
        }
        return {
          'success': false,
          'message': 'Sin conexión y no hay frase en cache',
        };
      }

      final userData = await LocalStorageService.getUserData();
      final token = userData['token'];

      final response = await http.get(
        Uri.parse('$baseUrl/daily-quote/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : '',
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

      if (response.statusCode == 200 && data['success'] == true) {
        await OfflineService.saveDailyQuote(data['data']);
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
          'message': data['message'] ?? 'Error al obtener la frase del día',
        };
      }
    } catch (e) {
      // Si falla la conexión, intentar cargar desde cache
      final cachedQuote = await OfflineService.getDailyQuote();
      if (cachedQuote != null) {
        return {'success': true, 'data': cachedQuote, 'offline': true};
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

  // Buscar emblemas (apellidos/familias)
  static Future<Map<String, dynamic>> searchEmblemas({
    required String name,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$emblemasUrl/emblemas'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name}),
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

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'No se encontraron resultados',
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
}
