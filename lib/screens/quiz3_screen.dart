import 'package:flutter/material.dart';
import 'quiz4_screen.dart';
import '../services/quiz_service.dart';
import '../services/notification_service.dart';
import '../main.dart';
import '../widgets/horario_selector.dart';

class Quiz3Screen extends StatefulWidget {
  const Quiz3Screen({Key? key}) : super(key: key);

  @override
  State<Quiz3Screen> createState() => _Quiz3ScreenState();
}

class _Quiz3ScreenState extends State<Quiz3Screen> {
  List<String> selectedChallenges = [];
  Map<String, TimeOfDay?> horariosPorDesafio = {};

  final List<Map<String, dynamic>> challenges = [
    {
      'title': 'Meditación Matutina',
      'key': 'meditacion_matutina',
      'description': '10 minutos cada mañana',
      'icon': Icons.self_improvement,
      'color': Colors.purple,
    },
    {
      'title': 'Reflexión Nocturna',
      'key': 'reflexion_nocturna',
      'description': 'Escribir 3 cosas del día',
      'icon': Icons.book,
      'color': Colors.blue,
    },
    {
      'title': 'Ejercicio Físico',
      'key': 'ejercicio_fisico',
      'description': '30 minutos de actividad',
      'icon': Icons.fitness_center,
      'color': Colors.green,
    },
    {
      'title': 'Lectura Estoica',
      'key': 'lectura_estoica',
      'description': '15 minutos diarios',
      'icon': Icons.menu_book,
      'color': Colors.indigo,
    },
    {
      'title': 'Acto de Bondad',
      'key': 'acto_de_bondad',
      'description': 'Una buena acción diaria',
      'icon': Icons.favorite,
      'color': Colors.red,
    },
    {
      'title': 'Tiempo en Silencio',
      'key': 'tiempo_en_silencio',
      'description': '20 minutos sin dispositivos',
      'icon': Icons.phone_disabled,
      'color': Colors.teal,
    },
    {
      'title': 'Práctica de Gratitud',
      'key': 'practica_de_gratitud',
      'description': 'Agradecer 5 cosas diarias',
      'icon': Icons.star,
      'color': Colors.amber,
    },
    {
      'title': 'Control Emocional',
      'key': 'control_emocional',
      'description': 'Pausar antes de reaccionar',
      'icon': Icons.psychology_alt,
      'color': Colors.deepPurple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    // ✅ Cargar datos guardados desde SharedPreferences
    await QuizService.loadFromPreferences();

    // Cargar datos guardados si existen
    final quiz = QuizService.currentQuiz;
    if (quiz.isQuiz3Complete()) {
      setState(() {
        selectedChallenges = quiz.dailyChallenges;
      });
    }
  }

  void _toggleChallenge(String challenge) {
    setState(() {
      if (selectedChallenges.contains(challenge)) {
        selectedChallenges.remove(challenge);
        horariosPorDesafio.remove(challenge);
      } else {
        selectedChallenges.add(challenge);
        horariosPorDesafio[challenge] = null;
      }
    });
  }

  Future<void> _continueToNext() async {
    if (selectedChallenges.isEmpty) {
      return;
    }

    // Guardar datos en el servicio
    QuizService.updateQuiz3(dailyChallenges: selectedChallenges);

    // Programar notificaciones para los desafíos con horario
    for (final challengeKey in selectedChallenges) {
      final horario = horariosPorDesafio[challengeKey];
      if (horario != null) {
        // Encontrar el título del desafío
        final challenge = challenges.firstWhere(
          (c) => c['key'] == challengeKey,
          orElse: () => {'title': challengeKey, 'description': ''},
        );

        final notificationId = NotificationService.getReminderNotificationId(
          challengeKey,
        );

        await NotificationService.scheduleDailyNotification(
          id: notificationId,
          title: '🏛️ ${challenge['title']}',
          body: challenge['description'] as String,
          time: horario,
          scheduledTime: horario,
        );
      }
    }

    if (mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Quiz4Screen()));
    }
  }

  void _goBackToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
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

                // Indicador de progreso
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: const Text(
                    'Paso 3 de 5',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Ícono circular
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade300, Colors.orange.shade600],
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 40),

                // Título
                const Text(
                  'Desafíos Diarios',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                const Text(
                  '¿Qué recordatorio te gustaría incluir en tu rutina?',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const Text(
                  'Elige los que sientes que puedes mantener',
                  style: TextStyle(color: Colors.orange, fontSize: 14),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Lista de desafíos
                ...challenges.map((challenge) {
                  final isSelected = selectedChallenges.contains(
                    challenge['key'],
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _toggleChallenge(challenge['key']),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.grey[900],
                              border: Border.all(
                                color:
                                    isSelected ? Colors.orange : Colors.white24,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                // Ícono
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: challenge['color'].withOpacity(
                                      0.2,
                                    ),
                                  ),
                                  child: Icon(
                                    challenge['icon'],
                                    color: challenge['color'],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Textos
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        challenge['title'],
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.orange
                                              : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        challenge['description'],
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.orange.shade200
                                              : Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Indicador de selección
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.orange
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.orange
                                          : Colors.white24,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              left: 8,
                              right: 8,
                            ),
                            child: HorarioSelector(
                              horaSeleccionada:
                                  horariosPorDesafio[challenge['key']],
                              onHoraSeleccionada: (hora) {
                                setState(() {
                                  horariosPorDesafio[challenge['key']] = hora;
                                });
                              },
                              label: 'Horario para este recordatorio',
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 40),

                // Indicador de progreso
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${selectedChallenges.length} recordatorios seleccionados',
                      style: TextStyle(
                        color: selectedChallenges.isNotEmpty
                            ? Colors.orange
                            : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (selectedChallenges.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 20),

                // Botón Continuar
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        selectedChallenges.isNotEmpty
                            ? Colors.orange.shade400
                            : Colors.grey.shade600,
                        selectedChallenges.isNotEmpty
                            ? Colors.orange.shade600
                            : Colors.grey.shade800,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        selectedChallenges.isNotEmpty ? _continueToNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botón Más Tarde
                TextButton(
                  onPressed: _goBackToHome,
                  child: const Text(
                    'Más Tarde',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
