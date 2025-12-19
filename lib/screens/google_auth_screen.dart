import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'quiz1_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:app_links/app_links.dart';

class GoogleAuthScreen extends StatefulWidget {
  const GoogleAuthScreen({Key? key}) : super(key: key);

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
    if (uri.scheme == 'estoico' && uri.host == 'auth') {
      if (uri.path.contains('success')) {
        _handleAuthSuccess(uri.toString());
      } else if (uri.path.contains('error')) {
        _handleAuthError(uri.toString());
      }
    }
  }

  Future<void> _initAuth() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Obtener la URL de autenticación del backend
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/auth/google/redirect'),
      );

      String authUrl = '${ApiService.baseUrl}/auth/google/redirect';

      // Si el backend devuelve JSON con la URL
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['data'] != null && data['data']['url'] != null) {
            authUrl = data['data']['url'];
          }
        } catch (e) {}
      }

      // Modificar redirect_uri y agregar prompt=select_account
      final uri = Uri.parse(authUrl);
      final params = Map<String, dynamic>.from(uri.queryParameters);

      // Cambiar localhost por ngrok en redirect_uri para móvil
      if (params.containsKey('redirect_uri')) {
        String redirectUri = params['redirect_uri'].toString();
        if (redirectUri.contains('localhost')) {
          // Reemplazar localhost con el dominio ngrok del backend
          redirectUri = redirectUri.replaceAll(
            'http://localhost:8000',
            ApiService.baseUrl.replaceAll('/api', ''),
          );
          params['redirect_uri'] = redirectUri;
        }
      }

      if (!params.containsKey('prompt')) {
        params['prompt'] = 'select_account';
      }

      authUrl = uri.replace(queryParameters: params).toString();

      // Abrir Chrome Custom Tab
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
            content: Text('Error al conectar con el servidor: $e'),
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

    if (token != null && userId != null) {
      // Guardar los datos del usuario
      await ApiService.saveUserData(
        token: token,
        userId: userId,
        nombre: nombre,
        apellidos: apellidos,
        email: email,
      );

      // Navegar al Quiz1 si es nuevo usuario, sino al Home
      if (mounted) {
        if (isNewUser) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Quiz1Screen()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } else {
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
