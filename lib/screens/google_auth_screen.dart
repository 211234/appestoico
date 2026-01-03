import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import '../services/api_service.dart';
import '../main.dart';
import 'quiz1_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthScreen extends StatefulWidget {
  final String authUrl;

  const GoogleAuthScreen({
    Key? key,
    this.authUrl = 'https://web.estoico.app/api/auth/google/redirect',
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

  void _handleDeepLink(Uri uri) {
    print('🔗 Deep link recibido: $uri');
    
    // Manejar deep link de la app: estoico://auth/success?token=...
    if (uri.scheme == 'estoico' && uri.host == 'auth') {
      if (uri.path.contains('success') || uri.queryParameters.containsKey('token')) {
        print('✅ Procesando autenticación exitosa');
        _handleAuthSuccess(uri.toString());
      } else if (uri.path.contains('error')) {
        print('❌ Error en autenticación');
        _handleAuthError(uri.toString());
      }
    } 
    // También manejar si el backend redirige con token en cualquier formato
    else if (uri.queryParameters.containsKey('token')) {
      print('✅ Token encontrado en parámetros, procesando...');
      _handleAuthSuccess(uri.toString());
    }
  }


  Future<void> _initAuth() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Obtener la URL de autenticación del backend
      final response = await http.get(Uri.parse(widget.authUrl));

      String authUrl = widget.authUrl;

      // El backend devuelve JSON con la URL de Google
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['success'] == true &&
              data['data'] != null &&
              data['data']['url'] != null) {
            // Extraer la URL real de Google del JSON
            authUrl = data['data']['url'];
          }
        } catch (e) {
          // Si no es JSON, usar la URL original
        }
      }

      // Agregar prompt=select_account si no está presente
      final uri = Uri.parse(authUrl);
      final params = Map<String, dynamic>.from(uri.queryParameters);

      if (!params.containsKey('prompt')) {
        params['prompt'] = 'select_account';
      }

      authUrl = uri.replace(queryParameters: params).toString();

      // Abrir Chrome Custom Tab con la URL de Google
      await _launchURL(authUrl);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
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

    print('📋 Datos extraídos: token=${token != null ? "✓" : "✗"}, userId=${userId != null ? "✓" : "✗"}, isNewUser=$isNewUser');

    if (token != null && userId != null) {
      try {
        // Guardar los datos básicos del usuario primero
        await ApiService.saveUserData(
          token: token,
          userId: userId,
          nombre: nombre,
          apellidos: apellidos,
          email: email,
        );

        print('✅ Datos básicos del usuario guardados');

        // Obtener la suscripción del usuario después del login
        // El backend no devuelve la suscripción en /api/users/me, así que hacemos una petición directa
        try {
          // Hacer petición directa a /api/users/me para obtener la suscripción
          final subscriptionResponse = await http.get(
            Uri.parse('https://web.estoico.app/api/users/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));
          
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
          }
        } catch (e) {
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
        print('❌ Error al guardar datos o navegar: $e');
        _handleAuthError(url);
      }
    } else {
      print('❌ Faltan datos requeridos: token o userId');
      _handleAuthError(url);
    }
  }

  void _handleAuthError([String? url]) {
    if (mounted) {
      String errorMessage = 'Error en la autenticación con Google';

      if (url != null) {
        final uri = Uri.parse(url);
        final message =
            uri.queryParameters['message'] ?? uri.queryParameters['error'];
        if (message != null) {
          errorMessage = message;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
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
