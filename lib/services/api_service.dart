import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'offline_service.dart';
import 'connectivity_service.dart';
import '../models/reflection.dart';

class ApiService {
  static const String baseUrl = 'https://web.estoico.app/api';

  static const String emblemasUrl = 'https://api.estoico.app/api';

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

      // Verificar si la respuesta tiene contenido
      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'El servidor no respondió correctamente',
        };
      }

      // Intentar decodificar JSON
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
        // Verificar si el backend devuelve success: true/false
        if (data['success'] == false) {
          return {
            'success': false,
            'message': data['message'] ?? 'Error en el registro',
          };
        }

        // Si el backend devuelve la estructura con 'data' anidado
        // Ejemplo: {success: true, data: {user_id: 123, ...}}
        return {
          'success': true,
          'data':
              data['data'] ??
              data, // Usar data anidado si existe, sino usar data directamente
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      // Detectar errores de timeout o conexión
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

        await saveUserData(
          token: data['token'],
          userId: data['data']['id'],
          nombre: data['data']['nombre'],
          apellidos: data['data']['apellidos'],
          email: data['data']['email'],
        );

        // Verificar que se guardó correctamente
        final prefs = await SharedPreferences.getInstance();
        final savedToken = prefs.getString('token');

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

  // Guardar datos del usuario localmente
  static Future<void> saveUserData({
    required String token,
    required String userId,
    required String nombre,
    required String apellidos,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_id', userId);
    await prefs.setString('nombre', nombre);
    await prefs.setString('apellidos', apellidos);
    await prefs.setString('email', email);
  }

  // Obtener datos del usuario
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'user_id': prefs.getString('user_id'),
      'nombre': prefs.getString('nombre'),
      'apellidos': prefs.getString('apellidos'),
      'email': prefs.getString('email'),
    };
  }

  // Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

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

      final userData = await getUserData();
      final token = userData['token'];

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'No se encontró el token de autenticación',
        };
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/users/me'),
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
        // Verificar si tiene estructura {success: true, data: {user: {...}}}
        if (data['success'] == true && data['data'] != null) {
          // Guardar en cache
          final profileData = data['data']['user'] ?? data['data'];
          await OfflineService.saveUserProfile(profileData);

          // Si la data tiene un campo 'user', usar ese
          if (data['data']['user'] != null) {
            return {'success': true, 'data': data['data']['user']};
          }
          // Si no, devolver data directamente
          return {'success': true, 'data': data['data']};
        }
        // O si la data está directamente en la respuesta
        else if (data['nombre'] != null || data['email'] != null) {
          return {'success': true, 'data': data};
        }
        // Si hay data pero está vacía
        else {
          return {
            'success': false,
            'message': 'El perfil está vacío. Por favor completa el quiz.',
          };
        }
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

      final userData = await getUserData();
      final token = userData['token'];

      final response = await http
          .get(
            Uri.parse('$baseUrl/daily-quote/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': token != null ? 'Bearer $token' : '',
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

      if (response.statusCode == 200 && data['success'] == true) {
        // Guardar en cache
        await OfflineService.saveDailyQuote(data['data']);
        return {'success': true, 'data': data['data']};
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
    String? knowledgeLevel,
  }) async {
    try {
      // Obtener el token del usuario
      final userData = await getUserData();
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
              'knowledge_level': knowledgeLevel,
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

      // Aceptar tanto 200 como 201 como respuestas exitosas
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

      final userData = await getUserData();
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
        // Guardar en cache
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
          'token':
              data['reset_token'], // El backend debería devolver un token temporal
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

  // Actualizar información básica del quiz (age_range, gender, country, religious_belief)
  static Future<Map<String, dynamic>> updateQuizInfo({
    required String ageRange,
    required String gender,
    required String country,
    required String religiousBelief,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

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

  // ========== MÉTODOS DE DIARIO (DIARY SERVICE) ==========

  // Obtener todas las reflexiones del usuario
  static Future<Map<String, dynamic>> getAllReflections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

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
        // El endpoint /all devuelve un array en data
        if (data['data'] != null && data['data'] is List) {
          final List<dynamic> reflectionsJson = data['data'];
          final List<Reflection> reflections = reflectionsJson
              .map((json) => Reflection.fromJson(json))
              .toList();
          return {'success': true, 'data': reflections};
        } else {
          // No hay reflexiones todavía
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

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

  // Crear/actualizar reflexión
  static Future<Map<String, dynamic>> saveMorningReflection({
    required String date,
    required String morningText,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

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
            body: jsonEncode({
              'text': morningText,
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

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

  // Guardar reflexión (método de compatibilidad)
  static Future<void> saveReflection({
    required String date,
    required String eveningText,
  }) async {}
}
