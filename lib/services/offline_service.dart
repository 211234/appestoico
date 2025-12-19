import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineService {
  // Keys para almacenamiento
  static const String _userProfileKey = 'cached_user_profile';
  static const String _dailyQuoteKey = 'cached_daily_quote';
  static const String _quizDataKey = 'cached_quiz_data';
  static const String _pendingReflectionsKey = 'pending_reflections';
  static const String _lastSyncKey = 'last_sync_timestamp';

  // Guardar perfil de usuario
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile));
  }

  // Obtener perfil de usuario
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userProfileKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  // Guardar frase del día
  static Future<void> saveDailyQuote(Map<String, dynamic> quote) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyQuoteKey, jsonEncode(quote));
    await prefs.setString('quote_date', DateTime.now().toIso8601String());
  }

  // Obtener frase del día
  static Future<Map<String, dynamic>?> getDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_dailyQuoteKey);
    final quoteDate = prefs.getString('quote_date');

    // Verificar si la frase es del día actual
    if (data != null && quoteDate != null) {
      final savedDate = DateTime.parse(quoteDate);
      final today = DateTime.now();

      if (savedDate.year == today.year &&
          savedDate.month == today.month &&
          savedDate.day == today.day) {
        return jsonDecode(data);
      } else {}
    }
    return null;
  }

  // Guardar datos del quiz
  static Future<void> saveQuizData(Map<String, dynamic> quizData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quizDataKey, jsonEncode(quizData));
  }

  // Obtener datos del quiz
  static Future<Map<String, dynamic>?> getQuizData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_quizDataKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  // Guardar reflexión pendiente (sin conexión)
  static Future<void> savePendingReflection(
    Map<String, dynamic> reflection,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingList = await getPendingReflections();
    pendingList.add(reflection);
    await prefs.setString(_pendingReflectionsKey, jsonEncode(pendingList));
  }

  // Obtener reflexiones pendientes
  static Future<List<Map<String, dynamic>>> getPendingReflections() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_pendingReflectionsKey);
    if (data != null) {
      final List<dynamic> list = jsonDecode(data);
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Limpiar reflexiones sincronizadas
  static Future<void> clearPendingReflections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingReflectionsKey);
  }

  // Actualizar timestamp de última sincronización
  static Future<void> updateLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  // Obtener última sincronización
  static Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_lastSyncKey);
    if (data != null) {
      return DateTime.parse(data);
    }
    return null;
  }

  // Limpiar todo el cache (logout)
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
    await prefs.remove(_dailyQuoteKey);
    await prefs.remove(_quizDataKey);
    await prefs.remove(_pendingReflectionsKey);
    await prefs.remove(_lastSyncKey);
    await prefs.remove('quote_date');
  }

  // Verificar si hay datos en cache
  static Future<bool> hasCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userProfileKey) ||
        prefs.containsKey(_dailyQuoteKey) ||
        prefs.containsKey(_quizDataKey);
  }
}
