import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar datos locales del usuario
class LocalStorageService {
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

  // Obtener token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
