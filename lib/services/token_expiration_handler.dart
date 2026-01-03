import 'package:flutter/material.dart';
import 'api/local_storage_service.dart';

/// Manejador centralizado para detectar y gestionar expiración de tokens
class TokenExpirationHandler {
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Inicializar el manejador con la clave del navegador
  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Verificar si la respuesta indica que el token ha expirado (401)
  /// Si es así, cierra la sesión y navega a login
  static Future<bool> handleTokenExpiration(int statusCode) async {
    if (statusCode == 401) {
      // Token expirado o inválido
      await _logout();
      return true;
    }
    return false;
  }

  /// Cerrar sesión y navegar a login
  static Future<void> _logout() async {
    // Eliminar datos de sesión
    await LocalStorageService.logout();

    // Navegar a la pantalla de login si el navegador está disponible
    if (_navigatorKey?.currentContext != null) {
      // Importar después para evitar circular dependencies
      // ignore: avoid_dynamic_call
      _navigatorKey?.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  /// Alternativamente, usar este método si tienes acceso al contexto
  static Future<void> logoutWithContext(BuildContext context) async {
    // Eliminar datos de sesión
    await LocalStorageService.logout();

    // Mostrar un diálogo informando que la sesión expiró
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sesión Expirada'),
          content: const Text(
            'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Navegar a login
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
