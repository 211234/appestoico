import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/offline_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/sweet_alert.dart';
import 'quiz2_screen.dart';
import 'edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _quizData;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNotificationTime();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.getUserProfile();

    if (result['success'] && result['data'] != null) {
      setState(() {
        _userData = result['data'];
      });

      // Si el quiz está completado, cargar los datos del quiz
      if (_userData?['quizCompleted'] == true) {
        await _loadQuizData();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        SweetAlert.showError(
          context: context,
          title: 'Error',
          message: result['message'] ?? 'No se pudo cargar tu perfil',
        );
      }
    }
  }

  Future<void> _loadQuizData() async {
    final result = await ApiService.getQuizData();

    if (result['success'] && result['data'] != null) {
      setState(() {
        _quizData = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // No mostrar error si no se pueden cargar los datos del quiz
      // El usuario aún puede ver su perfil básico
    }
  }

  Future<void> _loadNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notification_hour') ?? 8;
    final minute = prefs.getInt('notification_minute') ?? 0;
    setState(() {
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _changeNotificationTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notification_hour', picked.hour);
      await prefs.setInt('notification_minute', picked.minute);

      // Reagendar las notificaciones
      await NotificationService().scheduleDailyReminder(
        hour: picked.hour,
        minute: picked.minute,
      );

      setState(() {
        _notificationTime = picked;
      });

      SweetAlert.showSuccess(
        context: context,
        title: 'Horario actualizado',
        message:
            'Tu recordatorio diario llegará a las ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
        backgroundColor: const Color(0xFF102110),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Limpiar cache offline
    await OfflineService.clearAllCache();

    // Limpiar callbacks de conectividad
    ConnectivityService.clearCallbacks();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  Future<void> _showPremiumDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.workspace_premium, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Hacerse Premium', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            '¿Deseas ir a la página web para suscribirte a Estoica Premium?',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _launchPremiumUrl();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchPremiumUrl() async {
    try {
      // ✅ Obtener el token JWT del usuario
      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('token');

      if (jwtToken == null || jwtToken.isEmpty) {
        if (mounted) {
          SweetAlert.showError(
            context: context,
            title: 'Sesión expirada',
            message: 'Por favor, inicia sesión nuevamente',
          );
        }
        return;
      }

      // ✅ Construir URL con el token JWT como parámetro
      final url = Uri.parse(
          'https://web.estoico.app/subscription/premium?token=$jwtToken');

      // ✅ Abrir URL directamente
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          SweetAlert.showError(
            context: context,
            title: 'Error',
            message: 'No se pudo abrir la página web',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SweetAlert.showError(
          context: context,
          title: 'Error',
          message: 'Ocurrió un error: $e',
        );
      }
    }
  }

  void _completeProfile() {
    // Continuar con Quiz2 para completar el perfil
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const Quiz2Screen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    if (_userData == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.orange,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Completa tu perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Necesitamos conocerte mejor para personalizar tu experiencia estoica',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _completeProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Completar Perfil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loadUserData,
                    child: const Text(
                      'Reintentar',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final nombre = _userData!['nombre'] ?? 'Usuario';
    final apellidos = _userData!['apellidos'] ?? '';
    final nombreCompleto = apellidos.isEmpty ? nombre : '$nombre $apellidos';
    final email = _userData!['email'] ?? '';

    final nivel = _userData!['nivel'] ?? 'Principiante';

    final quizCompleted = _userData!['quizCompleted'] == true;

    // Extraer datos del quiz
    final objetivos = _quizData?['stoic_paths'] as List<dynamic>? ?? [];
    final desafios = _quizData?['daily_challenges'] as List<dynamic>? ?? [];
    final edad = _quizData?['age_range'] as String?;
    final genero = _quizData?['gender'] as String?;
    final pais = _quizData?['country'] as String?;
    final creencias = [
      _quizData?['religious_belief'],
    ].where((e) => e != null).toList();

    // Si el quiz no está completo, mostrar pantalla especial
    if (!quizCompleted) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade300,
                          Colors.orange.shade600,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        nombre[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nombreCompleto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  // Mensaje para completar quiz
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          color: Colors.orange,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Completa tu Perfil Estoico',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Responde un breve cuestionario para personalizar tu experiencia y recibir contenido adaptado a tus intereses espirituales y objetivos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Botón para completar quiz
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _completeProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Completar Cuestionario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Si el quiz está completo, mostrar perfil completo
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadUserData,
            color: Colors.orange,
            backgroundColor: Colors.grey[900],
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Ícono principal
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade400,
                              Colors.orange.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Título
                      Text(
                        'Hola, $nombreCompleto',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Card: Perfil Estoico
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.account_balance,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getArchetype(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tu arquetipo estoico dominante',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Mostrar barras de progreso según objetivos estoicos
                            if (objetivos.isNotEmpty)
                              ..._buildDynamicProgressBars(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tus Objetivos Estoicos
                      Row(
                        children: const [
                          Icon(
                            Icons.double_arrow,
                            color: Colors.orange,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tus Objetivos Estoicos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Grid dinámico de objetivos
                      if (objetivos.isNotEmpty)
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: objetivos.map((objetivo) {
                            return _buildStrengthCard(
                              _formatObjective(objetivo.toString()),
                              _getObjectiveIcon(objetivo.toString()),
                              _getObjectiveColor(objetivo.toString()),
                            );
                          }).toList(),
                        )
                      else
                        const Text(
                          'No hay objetivos definidos',
                          style: TextStyle(color: Colors.white60),
                        ),

                      const SizedBox(height: 32),

                      // Recordatorios Diarios
                      Row(
                        children: const [
                          Icon(
                            Icons.track_changes,
                            color: Colors.orange,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tus Recordatorios Diarios',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      if (desafios.isNotEmpty)
                        ...desafios.map((desafio) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildRecommendationCard(
                              _getChallengeIcon(desafio.toString()),
                              _formatChallenge(desafio.toString()),
                              _getChallengeDescription(desafio.toString()),
                              _getChallengeColor(desafio.toString()),
                            ),
                          );
                        }).toList()
                      else
                        const Text(
                          'No hay recordatorios definidos',
                          style: TextStyle(color: Colors.white60),
                        ),

                      const SizedBox(height: 16),

                      // Información adicional del quiz
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow2(
                              'Edad',
                              edad ?? 'No especificado',
                              Icons.cake,
                            ),
                            const Divider(color: Colors.white24, height: 24),
                            _buildInfoRow2(
                              'Género',
                              genero ?? 'No especificado',
                              Icons.wc,
                            ),
                            const Divider(color: Colors.white24, height: 24),
                            _buildInfoRow2(
                              'País',
                              pais ?? 'No especificado',
                              Icons.flag,
                            ),
                            if (creencias.isNotEmpty) ...[
                              const Divider(color: Colors.white24, height: 24),
                              _buildInfoRow2(
                                'Creencia',
                                _formatBelief(creencias.first.toString()),
                                Icons.auto_awesome,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botón Premium
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade400,
                              Colors.orange.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.workspace_premium,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Estoica Premium',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Desbloquea todo el contenido',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _showPremiumDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Hacerse Premium',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.open_in_new,
                                      color: Colors.orange.shade700,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botón de cerrar sesión
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Botón de editar perfil (esquina superior derecha)
          Positioned(
            top: 20,
            right: 20,
            child: SafeArea(
              child: IconButton(
                onPressed: _navigateToEditProfile,
                icon: const Icon(Icons.edit, color: Colors.orange, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.orange, width: 1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEditProfile() async {
    // Preparar datos actuales del quiz
    final currentData = {
      'age_range': _quizData?['age_range'] ?? '',
      'gender': _quizData?['gender'] ?? '',
      'country': _quizData?['country'] ?? '',
      'religious_belief': _quizData?['religious_belief'] ?? '',
    };

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(currentData: currentData),
      ),
    );

    // Si se actualizó el perfil, recargar datos
    if (result == true) {
      _loadUserData();
    }
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.6), color.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    IconData icon,
    String title,
    String description,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Métodos helper para formatear y obtener datos dinámicos
  String _getArchetype() {
    final objetivos = _quizData?['stoic_paths'] as List<dynamic>? ?? [];
    if (objetivos.isEmpty) return 'El Estoico';

    final objetivosStr = objetivos.join(',').toLowerCase();
    if (objetivosStr.contains('paz interior') || objetivosStr.contains('paz')) {
      return 'El Sabio Reflexivo';
    } else if (objetivosStr.contains('autocontrol') ||
        objetivosStr.contains('disciplina')) {
      return 'El Guerrero Disciplinado';
    } else if (objetivosStr.contains('resiliencia') ||
        objetivosStr.contains('fortaleza')) {
      return 'El Guardián Resiliente';
    } else if (objetivosStr.contains('equilibrio') ||
        objetivosStr.contains('balance')) {
      return 'El Sabio Equilibrado';
    }
    return 'El Estoico';
  }

  List<Widget> _buildDynamicProgressBars() {
    final objetivos = _quizData?['stoic_paths'] as List<dynamic>? ?? [];
    List<Widget> bars = [];
    for (int i = 0; i < objetivos.length && i < 3; i++) {
      if (i > 0) bars.add(const SizedBox(height: 16));
      bars.add(
        _buildProgressBar(
          _formatObjective(objetivos[i].toString()),
          0.5 + (i * 0.15), // Valores progresivos
          _getObjectiveColor(objetivos[i].toString()),
        ),
      );
    }
    return bars;
  }

  String _formatObjective(String objective) {
    final map = {
      'Paz Interior': 'Paz Interior',
      'Autocontrol': 'Autocontrol',
      'Resiliencia': 'Resiliencia',
      'Equilibrio': 'Equilibrio',
      'paz interior': 'Paz Interior',
      'autocontrol': 'Autocontrol',
      'resiliencia': 'Resiliencia',
      'equilibrio': 'Equilibrio',
    };
    return map[objective] ?? objective;
  }

  IconData _getObjectiveIcon(String objective) {
    final map = {
      'Paz Interior': Icons.self_improvement,
      'Autocontrol': Icons.psychology,
      'Resiliencia': Icons.shield,
      'Equilibrio': Icons.balance,
    };
    return map[_formatObjective(objective)] ?? Icons.star;
  }

  Color _getObjectiveColor(String objective) {
    final map = {
      'Paz Interior': Colors.blue,
      'Autocontrol': Colors.purple,
      'Resiliencia': Colors.green,
      'Equilibrio': Colors.orange,
    };
    return map[_formatObjective(objective)] ?? Colors.grey;
  }

  String _formatChallenge(String challenge) {
    final map = {
      'meditacion_matutina': 'Meditación Matutina',
      'ejercicio_fisico': 'Ejercicio Físico',
      'lectura_diaria': 'Lectura Diaria',
      'gratitud_nocturna': 'Gratitud Nocturna',
      'control_emociones': 'Control de Emociones',
      'reflexion_vespertina': 'Reflexión Vespertina',
    };
    return map[challenge] ?? challenge.replaceAll('_', ' ').toUpperCase();
  }

  String _getChallengeDescription(String challenge) {
    final map = {
      'meditacion_matutina':
          'Dedica 10-15 minutos cada mañana a meditar y preparar tu mente',
      'ejercicio_fisico':
          'Mantén tu cuerpo activo con 30 minutos de ejercicio diario',
      'lectura_diaria': 'Lee textos estoicos para fortalecer tu sabiduría',
      'gratitud_nocturna': 'Reflexiona sobre lo positivo antes de dormir',
      'control_emociones': 'Practica la gestión consciente de tus emociones',
      'reflexion_vespertina': 'Evalúa tu día y aprende de tus experiencias',
    };
    return map[challenge] ?? 'Practica este desafío diariamente para crecer';
  }

  IconData _getChallengeIcon(String challenge) {
    final map = {
      'meditacion_matutina': Icons.wb_sunny,
      'ejercicio_fisico': Icons.fitness_center,
      'lectura_diaria': Icons.menu_book,
      'gratitud_nocturna': Icons.nightlight_round,
      'control_emociones': Icons.psychology_alt,
      'reflexion_vespertina': Icons.edit_note,
    };
    return map[challenge] ?? Icons.track_changes;
  }

  Color _getChallengeColor(String challenge) {
    final map = {
      'meditacion_matutina': Colors.orange,
      'ejercicio_fisico': Colors.green,
      'lectura_diaria': Colors.blue,
      'gratitud_nocturna': Colors.purple,
      'control_emociones': Colors.red,
      'reflexion_vespertina': Colors.teal,
    };
    return map[challenge] ?? Colors.grey;
  }

  String _formatBelief(String belief) {
    final map = {
      'catolico': 'Católico',
      'cristiano': 'Cristiano',
      'budista': 'Budista',
      'ateo': 'Ateo',
      'agnostico': 'Agnóstico',
      'espiritual': 'Espiritual',
      'otro': 'Otro',
    };
    return map[belief] ?? belief;
  }

  Widget _buildInfoRow2(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
