import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';

/// Servicio para autenticación (login, registro, recuperación de contraseña)
class AuthService {
  static const String baseUrl = 'https://web.estoico.app/api';

  // Registro de usuario
  static Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nombre': nombre,
              'apellidos': apellidos,
              'email': email,
              'password': password,
              'confirm_password': confirmPassword,
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
        return {
          'success': false,
          'message': 'Error de conexión:\nThe endpoint\n$baseUrl is offline.',
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == false) {
          return {
            'success': false,
            'message': data['message'] ?? 'Error en el registro',
          };
        }

        return {'success': true, 'data': data['data'] ?? data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        return {
          'success': false,
          'message': 'Error de conexión:\nThe endpoint\n$baseUrl is offline.',
        };
      }
      return {'success': false, 'message': 'Error de conexión:\n$e'};
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
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

      if (response.statusCode == 200 && data['success'] == true) {
        // Guardar token y datos del usuario
        await LocalStorageService.saveUserData(
          token: data['token'],
          userId: data['data']['id'].toString(),
          nombre: data['data']['nombre'],
          apellidos: data['data']['apellidos'],
          email: data['data']['email'],
        );

        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Credenciales incorrectas',
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

  // Solicitar restablecimiento de contraseña
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/request-password-reset'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
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

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Email enviado correctamente',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al enviar el email',
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

  // Verificar código de recuperación
  static Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/password/verify-code'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'code': code}),
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

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Código verificado correctamente',
          'token': data['reset_token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Código inválido o expirado',
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

  // Restablecer contraseña
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/users/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'code': code,
              'new_password': newPassword,
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
        return {
          'success': false,
          'message': 'Error al procesar la respuesta del servidor',
        };
      }

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Contraseña cambiada exitosamente',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al cambiar la contraseña',
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
