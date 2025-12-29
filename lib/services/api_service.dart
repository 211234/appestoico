// Este archivo actúa como puente para mantener compatibilidad con código existente
// Los nuevos servicios están organizados en lib/services/api/

import 'api/auth_service.dart';
import 'api/verification_service.dart';
import 'api/local_storage_service.dart';
import 'api/user_service.dart';
import 'api/quiz_service.dart';
import 'api/diary_service.dart';
import 'api/content_service.dart';

/// Clase puente que redirige a los servicios especializados
/// Para nuevo código, importa directamente los servicios de lib/services/api/
class ApiService {
  static const String baseUrl = 'https://web.estoico.app/api';
  static const String emblemasUrl = 'https://api.estoico.app/api';

  // ========== AUTENTICACIÓN ==========

  // Registro de usuario
  static Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
    required String confirmPassword,
  }) => AuthService.register(
    nombre: nombre,
    apellidos: apellidos,
    email: email,
    password: password,
    confirmPassword: confirmPassword,
  );

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) => AuthService.login(email: email, password: password);

  // Solicitar restablecimiento de contraseña
  static Future<Map<String, dynamic>> forgotPassword({required String email}) =>
      AuthService.forgotPassword(email: email);

  // Verificar código de recuperación
  static Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) => AuthService.verifyResetCode(email: email, code: code);

  // Restablecer contraseña
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) => AuthService.resetPassword(
    email: email,
    code: code,
    newPassword: newPassword,
    confirmPassword: confirmPassword,
  );

  // ========== VERIFICACIÓN ==========

  // Verificar código de email
  static Future<Map<String, dynamic>> verifyEmailCode({
    required String userId,
    required String code,
  }) => VerificationService.verifyEmailCode(userId: userId, code: code);

  // ========== ALMACENAMIENTO LOCAL ==========

  // Guardar datos del usuario localmente
  static Future<void> saveUserData({
    required String token,
    required String userId,
    required String nombre,
    required String apellidos,
    required String email,
  }) => LocalStorageService.saveUserData(
    token: token,
    userId: userId,
    nombre: nombre,
    apellidos: apellidos,
    email: email,
  );

  // Obtener datos del usuario
  static Future<Map<String, String?>> getUserData() =>
      LocalStorageService.getUserData();

  // Verificar si hay sesión activa
  static Future<bool> isLoggedIn() => LocalStorageService.isLoggedIn();

  // Cerrar sesión
  static Future<void> logout() => LocalStorageService.logout();

  // ========== PERFIL DE USUARIO ==========

  // Obtener perfil del usuario desde el servidor
  static Future<Map<String, dynamic>> getUserProfile() =>
      UserService.getUserProfile();

  // Actualizar información básica del quiz
  static Future<Map<String, dynamic>> updateQuizInfo({
    required String ageRange,
    required String gender,
    required String country,
    required String religiousBelief,
  }) => UserService.updateQuizInfo(
    ageRange: ageRange,
    gender: gender,
    country: country,
    religiousBelief: religiousBelief,
  );

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
  }) => UserService.updateProfile(
    ageRange: ageRange,
    gender: gender,
    country: country,
    religiousBelief: religiousBelief,
    spiritualPracticeLevel: spiritualPracticeLevel,
    spiritualPracticeFrequency: spiritualPracticeFrequency,
    stoicPaths: stoicPaths,
    stoicLevel: stoicLevel,
  );

  // ========== QUIZ ==========

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
  }) => QuizService.submitQuiz(
    ageRange: ageRange,
    gender: gender,
    country: country,
    religiousBelief: religiousBelief,
    spiritualPracticeLevel: spiritualPracticeLevel,
    spiritualPracticeFrequency: spiritualPracticeFrequency,
    dailyChallenges: dailyChallenges,
    stoicPaths: stoicPaths,
    stoicLevel: stoicLevel,
  );

  // Obtener datos del quiz completado
  static Future<Map<String, dynamic>> getQuizData() =>
      QuizService.getQuizData();

  // ========== DIARIO (REFLEXIONES) ==========

  // Obtener todas las reflexiones del usuario
  static Future<Map<String, dynamic>> getAllReflections() =>
      DiaryService.getAllReflections();

  // Obtener reflexión de una fecha específica
  static Future<Map<String, dynamic>> getReflectionByDate(String date) =>
      DiaryService.getReflectionByDate(date);

  // Crear/actualizar reflexión matutina
  static Future<Map<String, dynamic>> saveMorningReflection({
    required String date,
    required String morningText,
  }) =>
      DiaryService.saveMorningReflection(date: date, morningText: morningText);

  // Eliminar reflexión
  static Future<Map<String, dynamic>> deleteReflection(String id) =>
      DiaryService.deleteReflection(id);

  // Actualizar reflexión
  static Future<Map<String, dynamic>> updateReflection({
    required String id,
    String? morningText,
    String? eveningText,
  }) => DiaryService.updateReflection(
    id: id,
    morningText: morningText,
    eveningText: eveningText,
  );

  // Guardar reflexión (método de compatibilidad)
  static Future<void> saveReflection({
    required String date,
    required String eveningText,
  }) => DiaryService.saveReflection(date: date, eveningText: eveningText);

  // ========== CONTENIDO ==========

  // Obtener frase del día
  static Future<Map<String, dynamic>> getDailyQuote() =>
      ContentService.getDailyQuote();

  // Buscar emblemas (apellidos/familias)
  static Future<Map<String, dynamic>> searchEmblemas({required String name}) =>
      ContentService.searchEmblemas(name: name);
}
