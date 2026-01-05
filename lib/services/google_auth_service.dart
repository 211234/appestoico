import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class GoogleAuthService {
  // Configuración de Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // URL de tu API
  // Para pruebas locales: 'http://localhost:8000/api'
  // Para producción: 'https://web.estoico.app/api'
  static const String apiBaseUrl = 'https://web.estoico.app/api';

  /// Inicia sesión con Google
  /// Retorna un Map con 'success', 'token', 'user' y 'message'
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    // #region agent log
    try {
      final logFile = File('c:\\Users\\pedro\\OneDrive\\Escritorio\\frondHombreEstoico\\appestoico\\.cursor\\debug.log');
      await logFile.parent.create(recursive: true);
      await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"A","location":"google_auth_service.dart:21","message":"signInWithGoogle iniciado","data":{"scopes":_googleSignIn.scopes},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
    } catch (e) {
      print('Error escribiendo log inicial: $e');
    }
    // #endregion
    try {
      // Paso 1: Iniciar sesión con Google (muestra selector de cuentas)
      // #region agent log
      try {
        final logFile = File('c:\\Users\\pedro\\OneDrive\\Escritorio\\frondHombreEstoico\\appestoico\\.cursor\\debug.log');
        await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"A","location":"google_auth_service.dart:30","message":"Antes de _googleSignIn.signIn()","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      } catch (e) {
        print('Error escribiendo log antes de signIn: $e');
      }
      // #endregion
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // Usuario canceló el proceso
        return {
          'success': false,
          'message': 'El usuario canceló el inicio de sesión'
        };
      }

      // Paso 2: Obtener el access_token de Google
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        return {
          'success': false,
          'message': 'No se pudo obtener el token de acceso de Google'
        };
      }

      // Paso 3: Enviar el token a tu backend
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/google/token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'access_token': googleAuth.accessToken,
        }),
      );

      // Paso 4: Procesar la respuesta
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          // Paso 5: Guardar el token JWT y datos del usuario
          final jwtToken = data['data']['token'];
          final userData = data['data']['user'] ?? {};
          
          await _saveUserData(
            token: jwtToken,
            userId: userData['id']?.toString() ?? '',
            nombre: userData['nombre'] ?? googleUser.displayName ?? '',
            apellidos: userData['apellidos'] ?? '',
            email: userData['email'] ?? googleUser.email,
            subscription: userData['subscription'],
          );
          
          // Paso 6: Obtener perfil completo para asegurar que tenemos la suscripción actualizada
          try {
            final profileResult = await ApiService.getUserProfile();
            if (profileResult['success'] == true && profileResult['data'] != null) {
              // Actualizar datos del usuario con la información completa del perfil
              final profileData = profileResult['data'];
              await _saveUserData(
                token: jwtToken,
                userId: profileData['id']?.toString() ?? userData['id']?.toString() ?? '',
                nombre: profileData['nombre'] ?? userData['nombre'] ?? googleUser.displayName ?? '',
                apellidos: profileData['apellidos'] ?? userData['apellidos'] ?? '',
                email: profileData['email'] ?? userData['email'] ?? googleUser.email,
                subscription: profileResult['subscription'] ?? profileData['subscription'] ?? userData['subscription'],
              );
              
              // Actualizar userData con la información del perfil
              userData.addAll(profileData);
              if (profileResult['subscription'] != null) {
                userData['subscription'] = profileResult['subscription'];
              }
            }
          } catch (e) {
            // Si falla obtener el perfil, continuamos con los datos iniciales
            // No es crítico, el usuario puede actualizar después
          }
          
          // Retornar datos del usuario y token
          return {
            'success': true,
            'token': jwtToken,
            'user': userData,
            'isNewUser': data['data']['is_new_user'] ?? false,
            'message': data['message'] ?? 'Login exitoso'
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Error en el servidor'
          };
        }
      } else {
        // Error HTTP
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Error al conectar con el servidor',
            'statusCode': response.statusCode
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Error al conectar con el servidor (${response.statusCode})',
            'statusCode': response.statusCode
          };
        }
      }
    } catch (e, stackTrace) {
      // #region agent log
      try {
        final logFile = File('c:\\Users\\pedro\\OneDrive\\Escritorio\\frondHombreEstoico\\appestoico\\.cursor\\debug.log');
        await logFile.parent.create(recursive: true);
        final errorData = {
          "sessionId": "debug-session",
          "runId": "run1",
          "hypothesisId": "A",
          "location": "google_auth_service.dart:144",
          "message": "Error capturado en signInWithGoogle",
          "data": {
            "errorType": e.runtimeType.toString(),
            "errorString": e.toString(),
            "errorCode": e is PlatformException ? e.code : null,
            "errorMessage": e is PlatformException ? e.message : null,
            "errorDetails": e is PlatformException ? e.details?.toString() : null,
            "stackTrace": stackTrace.toString().substring(0, stackTrace.toString().length > 2000 ? 2000 : stackTrace.toString().length)
          },
          "timestamp": DateTime.now().millisecondsSinceEpoch
        };
        await logFile.writeAsString('${jsonEncode(errorData)}\n', mode: FileMode.append);
        print('📝 Log escrito: Error capturado');
      } catch (logError) {
        print('❌ Error escribiendo log: $logError');
        print('❌ Error original: $e');
      }
      // #endregion
      
      // Error de red o excepción
      String errorMessage = 'Error al iniciar sesión con Google';
      
      // Manejar errores específicos de Google Sign-In
      if (e.toString().contains('ApiException: 10') || (e is PlatformException && e.code == 'sign_in_failed')) {
        // #region agent log
        try {
          final logFile = File('c:\\Users\\pedro\\OneDrive\\Escritorio\\frondHombreEstoico\\appestoico\\.cursor\\debug.log');
          await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"B","location":"google_auth_service.dart:156","message":"ApiException: 10 detectado - Error de configuración","data":{"error":e.toString(),"errorType":e.runtimeType.toString(),"packageName":"com.example.estoico","isPlatformException":e is PlatformException},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        } catch (_) {}
        // #endregion
        errorMessage = 'Error de configuración: Necesitas crear un OAuth Client ID de tipo ANDROID (no Web) en Google Cloud Console. Package name: com.example.estoico. Ver CONFIGURACION_GOOGLE_OAUTH_ANDROID.md';
      } else if (e.toString().contains('sign_in_failed')) {
        // #region agent log
        try {
          final logFile = File('c:\\Users\\pedro\\OneDrive\\Escritorio\\frondHombreEstoico\\appestoico\\.cursor\\debug.log');
          await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"C","location":"google_auth_service.dart:191","message":"sign_in_failed detectado","data":{"error":e.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        } catch (_) {}
        // #endregion
        errorMessage = 'Error de autenticación: Verifica la configuración de Google Sign-In en Google Cloud Console';
      } else if (e.toString().contains('NetworkError')) {
        // #region agent log
        try {
          final logFile = File('c:\\Users\\pedro\\OneDrive\\Escritorio\\frondHombreEstoico\\appestoico\\.cursor\\debug.log');
          await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"D","location":"google_auth_service.dart:199","message":"NetworkError detectado","data":{"error":e.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        } catch (_) {}
        // #endregion
        errorMessage = 'Error de conexión: Verifica tu conexión a internet';
      } else {
        // #region agent log
        try {
          final logFile = File('c:\\Users\\pedro\\OneDrive\\Escritorio\\frondHombreEstoico\\appestoico\\.cursor\\debug.log');
          await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"E","location":"google_auth_service.dart:207","message":"Error desconocido","data":{"error":e.toString(),"errorType":e.runtimeType.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        } catch (_) {}
        // #endregion
        errorMessage = 'Error: ${e.toString()}';
      }
      
      // #region agent log
      try {
        final logFile = File('c:\\Users\\pedro\\OneDrive\\Escritorio\\frondHombreEstoico\\appestoico\\.cursor\\debug.log');
        await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"A","location":"google_auth_service.dart:219","message":"Retornando error al usuario","data":{"errorMessage":errorMessage},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      } catch (_) {}
      // #endregion
      
      return {
        'success': false,
        'message': errorMessage
      };
    }
  }

  /// Cierra sesión de Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _removeToken();
  }

  /// Verifica si el usuario ya está autenticado
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Obtiene el usuario actual de Google
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return await _googleSignIn.signInSilently();
  }

  // ========== Métodos privados para manejo de tokens ==========

  /// Guarda el token JWT y datos del usuario en SharedPreferences
  Future<void> _saveUserData({
    required String token,
    required String userId,
    required String nombre,
    required String apellidos,
    required String email,
    Map<String, dynamic>? subscription,
  }) async {
    // Usar LocalStorageService para mantener consistencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_id', userId); // Usar 'user_id' para consistencia
    await prefs.setString('nombre', nombre);
    await prefs.setString('apellidos', apellidos);
    await prefs.setString('email', email);
    
    if (subscription != null) {
      await prefs.setString('subscription', jsonEncode(subscription));
    }
  }

  /// Obtiene el token JWT guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Elimina el token JWT y datos del usuario
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id'); // Usar 'user_id' para consistencia
    await prefs.remove('nombre');
    await prefs.remove('apellidos');
    await prefs.remove('email');
    await prefs.remove('subscription');
  }
}

