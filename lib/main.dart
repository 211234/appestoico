import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'services/connectivity_service.dart';
import 'services/token_expiration_handler.dart';
import 'config/app_config.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/subscription_success_screen.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno (con manejo de errores)
  try {
    await AppConfig.load();
  } catch (e) {
    print('⚠️ Error cargando .env: $e');
    // Continuar con valores por defecto
  }

  // Inicializar servicio de notificaciones (con manejo de errores)
  try {
    await NotificationService.initialize();
    // Reprogramar notificaciones guardadas
    await NotificationService.rescheduleAllNotifications();
  } catch (e) {
    print('⚠️ Error inicializando notificaciones: $e');
    // Continuar sin notificaciones
  }

  // Inicializar monitoreo de conectividad (con manejo de errores)
  try {
    await ConnectivityService.initialize();
  } catch (e) {
    print('⚠️ Error inicializando conectividad: $e');
    // Continuar sin monitoreo de conectividad
  }

  // Ejecutar la app (siempre, incluso si hay errores)
  runApp(const EstoicoApp());
}

class EstoicoApp extends StatefulWidget {
  const EstoicoApp({Key? key}) : super(key: key);

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  static void _initializeTokenHandler() {
    TokenExpirationHandler.initialize(_navigatorKey);
  }

  @override
  State<EstoicoApp> createState() => _EstoicoAppState();
}

class _EstoicoAppState extends State<EstoicoApp> {
  StreamSubscription? _deepLinkSubscription;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
    EstoicoApp._initializeTokenHandler();
  }

  void _initializeDeepLinks() {
    // Escuchar deep links en tiempo real
    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('Error al procesar deep link: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    print('Deep link recibido: ${uri.toString()}');

    if (uri.host == 'subscription-success') {
      // Redirigir a la pantalla de suscripción exitosa
      EstoicoApp._navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/subscription-success',
        (route) => false,
      );
    } else if (uri.host == 'auth') {
      // Manejar auth callbacks
      EstoicoApp._navigatorKey.currentState?.pushNamed('/login');
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      navigatorKey: EstoicoApp._navigatorKey,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/splash': (context) => const SplashScreen(),
        '/subscription-success': (context) => const SubscriptionSuccessScreen(),
      },
      builder: (context, widget) {
        // Capturar errores de renderizado
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Error al cargar la aplicación',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      errorDetails.exception.toString(),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const SplashScreen()),
                        );
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        };
        return widget ?? const SizedBox.shrink();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final int initialTabIndex;

  const HomePage({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  static const List<Widget> _screens = [
    HomeScreen(),
    GuideScreen(),
    ChallengesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 1,
          toolbarHeight: 5.0,
          automaticallyImplyLeading: false,
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white60,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Guía'),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Desafíos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
