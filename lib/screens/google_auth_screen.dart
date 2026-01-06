import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../config/app_config.dart';
import '../services/api_service.dart';
import '../main.dart';
import 'quiz1_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthScreen extends StatefulWidget {
  final String? authUrl;

  const GoogleAuthScreen({
    Key? key,
    this.authUrl,
  }) : super(key: key);

  @override
  State<GoogleAuthScreen> createState() => _GoogleAuthScreenState();
}

class _GoogleAuthScreenState extends State<GoogleAuthScreen> {
  bool _isLoading = true;
  StreamSubscription? _sub;
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initAuth();
    _initAppLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _initAppLinks() async {
    // Escuchar deep links mientras la app está abierta
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (err) {});

    // Verificar si la app se abrió con un deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {}
  }

  void _handleDeepLink(Uri uri) async {
    // #region agent log
    try {
      final logFile = await File('.cursor/debug.log').create(recursive: true);
      await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"D","location":"google_auth_screen.dart:59","message":"Deep link recibido","data":{"uri":uri.toString(),"scheme":uri.scheme,"host":uri.host,"path":uri.path,"queryParams":uri.queryParameters.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
    } catch (e) {
      print('⚠️ Error escribiendo log: $e');
    }
    // #endregion
    print('🔗 Deep link recibido: $uri');
    print('📋 Todos los parámetros del deep link: ${uri.queryParameters}');
    
    // Verificar si hay un error del backend (500, error, etc.)
    final errorParam = uri.queryParameters['error'] ?? uri.queryParameters['message'];
    final statusCode = uri.queryParameters['status_code'] ?? uri.queryParameters['statusCode'];
    
    print('🔍 Verificando errores: errorParam=$errorParam, statusCode=$statusCode');
    print('📋 Todos los query parameters: ${uri.queryParameters}');
    
    // #region agent log
    try {
      final logFile = await File('.cursor/debug.log').create(recursive: true);
      await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"E","location":"google_auth_screen.dart:70","message":"Verificando errores en deep link","data":{"hasError":errorParam != null,"error":errorParam,"statusCode":statusCode,"allParams":uri.queryParameters.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
    } catch (e) {
      print('⚠️ Error escribiendo log: $e');
    }
    // #endregion
    
    // Si hay un error o status code 500, manejar como error
    if (errorParam != null || statusCode == '500' || uri.path.contains('error')) {
      print('❌ ERROR DETECTADO EN DEEP LINK:');
      print('   - errorParam: $errorParam');
      print('   - statusCode: $statusCode');
      print('   - path: ${uri.path}');
      print('   - Todos los parámetros: ${uri.queryParameters}');
      
      // #region agent log
      try {
        final logFile = await File('.cursor/debug.log').create(recursive: true);
        await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"E","location":"google_auth_screen.dart:76","message":"Error detectado en deep link","data":{"error":errorParam,"statusCode":statusCode,"allParams":uri.queryParameters.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      } catch (e) {
        print('⚠️ Error escribiendo log: $e');
      }
      // #endregion
      _handleAuthError(uri.toString());
      return;
    }
    
    // Manejar deep link de la app: estoico://auth/success?token=...
    if (uri.scheme == 'estoico' && uri.host == 'auth') {
      if (uri.path.contains('success') || uri.queryParameters.containsKey('token')) {
        // #region agent log
        try {
          final logFile = await File('.cursor/debug.log').create(recursive: true);
          await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"D","location":"google_auth_screen.dart:85","message":"Procesando autenticación exitosa","data":{"hasToken":uri.queryParameters.containsKey('token'),"hasUserId":uri.queryParameters.containsKey('userId') || uri.queryParameters.containsKey('user_id')},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        } catch (_) {}
        // #endregion
        print('✅ Procesando autenticación exitosa');
        _handleAuthSuccess(uri.toString());
      }
    } 
    // También manejar si el backend redirige con token en cualquier formato
    else if (uri.queryParameters.containsKey('token')) {
      // #region agent log
      try {
        final logFile = await File('.cursor/debug.log').create(recursive: true);
        await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"D","location":"google_auth_screen.dart:94","message":"Token encontrado en parámetros","data":{"hasToken":true},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      } catch (_) {}
      // #endregion
      print('✅ Token encontrado en parámetros, procesando...');
      _handleAuthSuccess(uri.toString());
    } else {
      // #region agent log
      try {
        final logFile = await File('.cursor/debug.log').create(recursive: true);
        await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"D","location":"google_auth_screen.dart:100","message":"Deep link no reconocido","data":{"uri":uri.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      } catch (_) {}
      // #endregion
      print('⚠️ Deep link no reconocido: $uri');
    }
  }


  Future<void> _initAuth() async {
    // #region agent log
    try {
      final logFile = await File('.cursor/debug.log').create(recursive: true);
      await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"A","location":"google_auth_screen.dart:104","message":"_initAuth iniciado","data":{"authUrl":widget.authUrl},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
    } catch (_) {}
    // #endregion
    try {
      setState(() {
        _isLoading = true;
      });

      // Obtener la URL de autenticación del backend
      final authUrl = widget.authUrl ?? AppConfig.googleAuthRedirectUrl;
      print('🌐 Iniciando GET a: $authUrl');
      // #region agent log
      try {
        final logFile = await File('.cursor/debug.log').create(recursive: true);
        await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"A","location":"google_auth_screen.dart:117","message":"Antes de GET /api/auth/google/redirect","data":{"url":authUrl},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      } catch (e) {
        print('⚠️ Error escribiendo log: $e');
      }
      // #endregion
      final response = await http.get(Uri.parse(authUrl));
      print('📡 Respuesta recibida: Status ${response.statusCode}');
      print('📄 Body (primeros 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');
      
      // #region agent log
      try {
        final logFile = await File('.cursor/debug.log').create(recursive: true);
        await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"A","location":"google_auth_screen.dart:125","message":"Después de GET /api/auth/google/redirect","data":{"statusCode":response.statusCode,"body":response.body.length > 500 ? response.body.substring(0,500) : response.body},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      } catch (e) {
        print('⚠️ Error escribiendo log: $e');
      }
      // #endregion
      
      // Si el status code es 500, mostrar error detallado
      if (response.statusCode == 500) {
        print('❌ ERROR 500 DEL SERVIDOR EN GET /api/auth/google/redirect');
        print('📋 Body completo del error: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error 500 del servidor: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          Navigator.of(context).pop();
          return;
        }
      }

      String finalAuthUrl = widget.authUrl ?? AppConfig.googleAuthRedirectUrl;

      // El backend devuelve JSON con la URL de Google
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          // #region agent log
          try {
            final logFile = await File('.cursor/debug.log').create(recursive: true);
            await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"A","location":"google_auth_screen.dart:93","message":"JSON parseado exitosamente","data":{"hasSuccess":data['success'] != null,"hasData":data['data'] != null,"hasUrl":data['data']?['url'] != null},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
          } catch (_) {}
          // #endregion
          if (data['success'] == true &&
              data['data'] != null &&
              data['data']['url'] != null) {
            // Extraer la URL real de Google del JSON
            finalAuthUrl = data['data']['url'];
            // #region agent log
            try {
              final logFile = await File('.cursor/debug.log').create(recursive: true);
              await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"A","location":"google_auth_screen.dart:98","message":"URL de Google extraída","data":{"authUrl":authUrl.length > 200 ? authUrl.substring(0,200) : authUrl},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
            } catch (_) {}
            // #endregion
          }
        } catch (e) {
          // #region agent log
          try {
            final logFile = await File('.cursor/debug.log').create(recursive: true);
            await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"A","location":"google_auth_screen.dart:100","message":"Error al parsear JSON","data":{"error":e.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
          } catch (_) {}
          // #endregion
          // Si no es JSON, usar la URL original
        }
      } else {
        // #region agent log
        try {
          final logFile = await File('.cursor/debug.log').create(recursive: true);
          await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"A","location":"google_auth_screen.dart:103","message":"Status code no es 200","data":{"statusCode":response.statusCode,"body":response.body.length > 500 ? response.body.substring(0,500) : response.body},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        } catch (_) {}
        // #endregion
      }

      // Agregar prompt=select_account si no está presente
      final uri = Uri.parse(finalAuthUrl);
      final params = Map<String, dynamic>.from(uri.queryParameters);

      if (!params.containsKey('prompt')) {
        params['prompt'] = 'select_account';
      }

      finalAuthUrl = uri.replace(queryParameters: params).toString();

      // Abrir Chrome Custom Tab con la URL de Google
      await _launchURL(finalAuthUrl);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // #region agent log
      try {
        final logFile = await File('.cursor/debug.log').create(recursive: true);
        await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"A","location":"google_auth_screen.dart:121","message":"Excepción en _initAuth","data":{"error":e.toString(),"stackTrace":e is Error ? e.stackTrace.toString() : ""},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      } catch (_) {}
      // #endregion
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir navegador: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: Colors.black,
          ),
          shareState: CustomTabsShareState.off,
          urlBarHidingEnabled: true,
          showTitle: true,
        ),
        safariVCOptions: SafariViewControllerOptions(
          preferredBarTintColor: Colors.black,
          preferredControlTintColor: Colors.orange,
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el navegador: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAuthSuccess(String url) async {
    // #region agent log
    try {
      final logFile = await File('.cursor/debug.log').create(recursive: true);
      await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"B","location":"google_auth_screen.dart:169","message":"_handleAuthSuccess iniciado","data":{"url":url.length > 200 ? url.substring(0,200) : url},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
    } catch (_) {}
    // #endregion
    print('🔐 Procesando autenticación exitosa desde: $url');
    
    final uri = Uri.parse(url);
    final token = uri.queryParameters['token'];
    final userId =
        uri.queryParameters['userId'] ?? uri.queryParameters['user_id'];
    final nombre = uri.queryParameters['nombre'] ?? '';
    final apellidos = uri.queryParameters['apellidos'] ?? '';
    final email = uri.queryParameters['email'] ?? '';
    final isNewUser =
        uri.queryParameters['is_new_user'] == 'true' ||
        uri.queryParameters['isNewUser'] == 'true';

    // #region agent log
    try {
      final logFile = await File('.cursor/debug.log').create(recursive: true);
      await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"B","location":"google_auth_screen.dart:183","message":"Datos extraídos del deep link","data":{"hasToken":token != null,"hasUserId":userId != null,"isNewUser":isNewUser,"email":email},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
    } catch (_) {}
    // #endregion
    print('📋 Datos extraídos: token=${token != null ? "✓" : "✗"}, userId=${userId != null ? "✓" : "✗"}, isNewUser=$isNewUser');

    if (token != null && userId != null) {
      try {
        // Guardar los datos básicos del usuario primero
        // #region agent log
        try {
          final logFile = await File('.cursor/debug.log').create(recursive: true);
          await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"B","location":"google_auth_screen.dart:188","message":"Antes de saveUserData","data":{"userId":userId,"email":email},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        } catch (_) {}
        // #endregion
      await ApiService.saveUserData(
        token: token,
        userId: userId,
        nombre: nombre,
        apellidos: apellidos,
        email: email,
      );
        // #region agent log
        try {
          final logFile = await File('.cursor/debug.log').create(recursive: true);
          await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"B","location":"google_auth_screen.dart:196","message":"Después de saveUserData","data":{"success":true},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        } catch (_) {}
        // #endregion

        print('✅ Datos básicos del usuario guardados');

        // Obtener la suscripción del usuario después del login
        // El backend no devuelve la suscripción en /api/users/me, así que hacemos una petición directa
        try {
          // Hacer petición directa a /api/users/me para obtener la suscripción
          // #region agent log
          try {
            final logFile = await File('.cursor/debug.log').create(recursive: true);
            await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"C","location":"google_auth_screen.dart:202","message":"Antes de GET /api/users/me","data":{"isNewUser":isNewUser},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
          } catch (_) {}
          // #endregion
          final subscriptionResponse = await http.get(
            Uri.parse('${AppConfig.apiBaseUrl}/users/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));
          // #region agent log
          try {
            final logFile = await File('.cursor/debug.log').create(recursive: true);
            await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"C","location":"google_auth_screen.dart:210","message":"Después de GET /api/users/me","data":{"statusCode":subscriptionResponse.statusCode,"bodyLength":subscriptionResponse.body.length,"bodyPreview":subscriptionResponse.body.length > 500 ? subscriptionResponse.body.substring(0,500) : subscriptionResponse.body},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
          } catch (_) {}
          // #endregion
          
          if (subscriptionResponse.statusCode == 200) {
            final subscriptionData = json.decode(subscriptionResponse.body);
            
            // Intentar obtener la suscripción de diferentes ubicaciones en la respuesta
            Map<String, dynamic>? subscription;
            
            if (subscriptionData['subscription'] != null) {
              subscription = subscriptionData['subscription'];
            } else if (subscriptionData['data'] != null && subscriptionData['data']['subscription'] != null) {
              subscription = subscriptionData['data']['subscription'];
            } else if (subscriptionData['data'] != null && 
                       subscriptionData['data']['user'] != null && 
                       subscriptionData['data']['user']['subscription'] != null) {
              subscription = subscriptionData['data']['user']['subscription'];
            }
            
            if (subscription != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('subscription', jsonEncode(subscription));
              
              print('✅ Información de suscripción guardada: ${subscription['hasActiveSubscription']}, status: ${subscription['status']}');
            } else {
              print('⚠️ El backend no devolvió información de suscripción en /api/users/me');
              print('⚠️ Esto puede significar que el usuario no tiene suscripción activa o el backend necesita actualizarse');
            }
          } else {
            // #region agent log
            try {
              final logFile = await File('.cursor/debug.log').create(recursive: true);
              await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"C","location":"google_auth_screen.dart:235","message":"GET /api/users/me falló","data":{"statusCode":subscriptionResponse.statusCode,"body":subscriptionResponse.body.length > 500 ? subscriptionResponse.body.substring(0,500) : subscriptionResponse.body},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
            } catch (_) {}
            // #endregion
          }
        } catch (e) {
          // #region agent log
          try {
            final logFile = await File('.cursor/debug.log').create(recursive: true);
            await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"C","location":"google_auth_screen.dart:237","message":"Excepción al obtener suscripción","data":{"error":e.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
          } catch (_) {}
          // #endregion
          print('⚠️ No se pudo obtener la suscripción, pero el login fue exitoso: $e');
          // Continuar con el flujo aunque no se haya podido obtener la suscripción
        }

        // Pequeño delay para asegurar que la suscripción se guarde completamente
        await Future.delayed(const Duration(milliseconds: 300));

        print('✅ Datos del usuario guardados correctamente');

      // Navegar al Quiz1 si es nuevo usuario, sino al Home
      if (mounted) {
        if (isNewUser) {
            print('📝 Usuario nuevo, navegando a Quiz1');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Quiz1Screen()),
            (route) => false,
          );
        } else {
            print('🏠 Usuario existente, navegando a HomePage');
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
        }
      } catch (e) {
        // #region agent log
        try {
          final logFile = await File('.cursor/debug.log').create(recursive: true);
          await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"B","location":"google_auth_screen.dart:262","message":"Error al guardar datos o navegar","data":{"error":e.toString(),"stackTrace":e is Error ? e.stackTrace.toString() : ""},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        } catch (_) {}
        // #endregion
        print('❌ Error al guardar datos o navegar: $e');
        _handleAuthError(url);
      }
    } else {
      // #region agent log
      try {
        final logFile = await File('.cursor/debug.log').create(recursive: true);
        await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"B","location":"google_auth_screen.dart:266","message":"Faltan datos requeridos","data":{"hasToken":token != null,"hasUserId":userId != null},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      } catch (_) {}
      // #endregion
      print('❌ Faltan datos requeridos: token o userId');
      _handleAuthError(url);
    }
  }

  void _handleAuthError([String? url]) async {
    // #region agent log
    try {
      final logFile = await File('.cursor/debug.log').create(recursive: true);
      await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"E","location":"google_auth_screen.dart:272","message":"_handleAuthError llamado","data":{"url":url},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
    } catch (_) {}
    // #endregion
    
    if (mounted) {
      String errorMessage = 'Error en la autenticación con Google';
      String? detailedError;

      if (url != null) {
        final uri = Uri.parse(url);
        final message = uri.queryParameters['message'] ?? uri.queryParameters['error'];
        final statusCode = uri.queryParameters['status_code'] ?? uri.queryParameters['statusCode'];
        
        // #region agent log
        try {
          final logFile = await File('.cursor/debug.log').create(recursive: true);
          await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"E","location":"google_auth_screen.dart:282","message":"Extrayendo detalles del error","data":{"message":message,"statusCode":statusCode,"allParams":uri.queryParameters.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        } catch (_) {}
        // #endregion
        
        print('🔍 Extrayendo mensaje de error: message=$message, statusCode=$statusCode');
        
        if (message != null && message.isNotEmpty) {
          errorMessage = message;
          print('✅ Mensaje del backend establecido: $errorMessage');
        }
        
        // Si hay un error 500, usar el mensaje del backend directamente
        if (statusCode == '500') {
          // Usar el mensaje del backend si está disponible, sino mostrar mensaje genérico
          if (message != null && message.isNotEmpty) {
            errorMessage = message;
            detailedError = message; // Mostrar el mensaje real del backend
            print('✅ Error 500 - Usando mensaje del backend: $detailedError');
          } else {
            errorMessage = 'Error 500 del servidor: Error interno del servidor';
            detailedError = 'El servidor encontró un error al procesar tu solicitud. Por favor, intenta de nuevo más tarde.';
            print('⚠️ Error 500 - Mensaje del backend vacío, usando genérico');
          }
        }
      }

      // #region agent log
      try {
        final logFile = await File('.cursor/debug.log').create(recursive: true);
        await logFile.writeAsString('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"E","location":"google_auth_screen.dart:295","message":"Mostrando error al usuario","data":{"errorMessage":errorMessage,"detailedError":detailedError},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      } catch (_) {}
      // #endregion

      final messageToShow = detailedError ?? errorMessage;
      print('📢 Mostrando mensaje al usuario: $messageToShow');
      print('   - errorMessage: $errorMessage');
      print('   - detailedError: $detailedError');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messageToShow),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Iniciar sesión con Google',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 20),
                  Text(
                    'Abriendo navegador...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Inicia sesión con tu cuenta de Google',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.orange,
                    size: 64,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Esperando autenticación...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Por favor, completa el proceso en el navegador',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
