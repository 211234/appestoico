import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'services/connectivity_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar servicio de notificaciones
  await NotificationService.initialize();

  // Reprogramar notificaciones guardadas
  await NotificationService.rescheduleAllNotifications();

  // Inicializar monitoreo de conectividad
  await ConnectivityService.initialize();

  runApp(const EstoicoApp());
}

class EstoicoApp extends StatelessWidget {
  const EstoicoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
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
