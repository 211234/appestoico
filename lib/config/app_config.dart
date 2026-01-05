import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración centralizada de la aplicación
/// Todas las URLs y configuraciones importantes se obtienen de variables de entorno
class AppConfig {
  // URLs de la API
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://web.estoico.app/api';
  static String get emblemasUrl => dotenv.env['EMBLEMAS_URL'] ?? 'https://api.estoico.app/api';
  static String get webBaseUrl => dotenv.env['WEB_BASE_URL'] ?? 'https://web.estoico.app';
  
  // URLs específicas
  static String get googleAuthRedirectUrl => '$apiBaseUrl/auth/google/redirect';
  static String get subscriptionUrl => '$webBaseUrl/subscription/premium';
  
  // Deep links
  static String get deepLinkScheme => dotenv.env['DEEP_LINK_SCHEME'] ?? 'estoico';
  static String get deepLinkHost => dotenv.env['DEEP_LINK_HOST'] ?? 'auth';
  
  // Configuración de entorno
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  
  // Timeouts
  static int get apiTimeoutSeconds => int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '30') ?? 30;
  
  /// Inicializar la configuración cargando el archivo .env
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
      print('✅ Archivo .env cargado correctamente');
    } catch (e) {
      // Si no existe .env, usar valores por defecto
      print('⚠️ No se pudo cargar .env, usando valores por defecto: $e');
      // Asegurar que dotenv esté inicializado aunque falle la carga
      try {
        // Intentar cargar sin especificar archivo para inicializar
        await dotenv.load();
      } catch (_) {
        // Si también falla, continuar sin .env
      }
    }
  }
  
  /// Obtener una variable de entorno con valor por defecto
  static String getEnv(String key, String defaultValue) {
    return dotenv.env[key] ?? defaultValue;
  }
}

