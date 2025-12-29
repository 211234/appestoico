import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para verificación de códigos (email, etc)
class VerificationService {
  static const String baseUrl = 'https://web.estoico.app/api';

  // Verificar código de email
  static Future<Map<String, dynamic>> verifyEmailCode({
    required String userId,
    required String code,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/verifyemailcode'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'code': code}),
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
          'message': 'Error de conexión:\nEl servidor no está disponible',
        };
      }

      if (response.statusCode == 200) {
        // Devolver toda la respuesta para que se pueda extraer el token
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Código inválido',
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
