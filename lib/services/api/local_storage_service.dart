import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Servicio para gestionar datos locales del usuario
class LocalStorageService {
  // Guardar datos del usuario localmente
  static Future<void> saveUserData({
    required String token,
    required String userId,
    required String nombre,
    required String apellidos,
    required String email,
    Map<String, dynamic>? subscription,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_id', userId);
    await prefs.setString('nombre', nombre);
    await prefs.setString('apellidos', apellidos);
    await prefs.setString('email', email);
    
    // Guardar información de suscripción si está disponible
    if (subscription != null) {
      await prefs.setString('subscription', jsonEncode(subscription));
    }
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

  // Obtener información de suscripción
  static Future<Map<String, dynamic>?> getSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionStr = prefs.getString('subscription');
    if (subscriptionStr != null) {
      try {
        return jsonDecode(subscriptionStr);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Verificar si el usuario tiene suscripción activa
  static Future<bool> hasActiveSubscription() async {
    final subscription = await getSubscription();
    if (subscription != null) {
      final hasActive = subscription['hasActiveSubscription'] == true;
      
      // Verificar la fecha de fin del período actual
      DateTime? currentPeriodEnd;
      if (subscription['currentPeriodEnd'] != null) {
        try {
          // El formato es "2026-01-30 02:25:19" (MySQL datetime)
          final dateStr = subscription['currentPeriodEnd'].toString();
          currentPeriodEnd = DateTime.parse(dateStr.replaceAll(' ', 'T'));
        } catch (e) {
          print('⚠️ Error al parsear currentPeriodEnd: $e');
        }
      }
      
      // Si hay fecha de fin del período, verificar que aún no haya expirado
      if (currentPeriodEnd != null) {
        final now = DateTime.now();
        final isNotExpired = currentPeriodEnd.isAfter(now);
        
        // Si la suscripción tiene período activo (fecha futura) y hasActiveSubscription es true,
        // está activa incluso si el status es 'cancelled' o 'canceled'
        if (isNotExpired && hasActive) {
          return true;
        }
        
        // Si ya expiró, no está activa
        return false;
      }
      
      // Si no hay currentPeriodEnd, usar la lógica original
      // Solo está activa si el status es 'active'
      final status = subscription['status']?.toString().toLowerCase();
      return hasActive && status == 'active';
    }
    return false;
  }
}
