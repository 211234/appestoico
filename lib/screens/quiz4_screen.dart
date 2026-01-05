import 'package:estoico/main.dart';
import 'package:flutter/material.dart';
import '../widgets/sweet_alert.dart';
import '../services/quiz_service.dart';
import 'quiz5_screen.dart';

class Quiz4Screen extends StatefulWidget {
  const Quiz4Screen({Key? key}) : super(key: key);

  @override
  State<Quiz4Screen> createState() => _Quiz4ScreenState();
}

class _Quiz4ScreenState extends State<Quiz4Screen> {
  List<String> selectedGoals = []; // Cambiado a lista para selección múltiple

  final List<Map<String, dynamic>> goals = [
    {
      'title': 'Paz Interior',
      'key': 'paz_interior',
      'description': 'Encontrar calma en el caos diario',
      'icon': Icons.spa,
    },
    {
      'title': 'Autocontrol',
      'key': 'autocontrol',
      'description': 'Dominar mis emociones y reacciones',
      'icon': Icons.psychology,
    },
    {
      'title': 'Sabiduría',
      'key': 'sabiduria',
      'description': 'Desarrollar perspectiva y entendimiento',
      'icon': Icons.lightbulb,
    },
    {
      'title': 'Resiliencia',
      'key': 'resiliencia',
      'description': 'Ser fuerte ante las adversidades',
      'icon': Icons.shield,
    },
    {
      'title': 'Propósito',
      'key': 'proposito',
      'description': 'Encontrar significado en mi vida',
      'icon': Icons.track_changes,
    },
    {
      'title': 'Equilibrio',
      'key': 'equilibrio',
      'description': 'Balancear todas las áreas de mi vida',
      'icon': Icons.balance,
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
    if (quiz.isQuiz4Complete()) {
      setState(() {
        selectedGoals = quiz.stoicPaths;
      });
    }
  }

  Future<void> _finishSetup() async {
    if (selectedGoals.length < 2) {
      SweetAlert.showError(
        context: context,
        title: 'Selección incompleta',
        message: 'Por favor selecciona al menos 2 objetivos estoicos',
      );
      return;
    }

    // Guardar los objetivos seleccionados en QuizService
    await QuizService.updateQuiz4(stoicPaths: selectedGoals);

    // Navegar a Quiz5
    if (mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Quiz5Screen()));
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
                  'Paso 4 de 5',
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
                child: const Icon(Icons.flag, color: Colors.white, size: 40),
              ),

              const SizedBox(height: 40),

              // Título
              const Text(
                'Tu Camino Estoico',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                'Definamos tus objetivos y preferencias',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título con contador
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              '¿Cuáles son tus objetivos principales?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: selectedGoals.length >= 2
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedGoals.length >= 2
                                    ? Colors.orange
                                    : Colors.grey[600]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${selectedGoals.length}/6',
                              style: TextStyle(
                                color: selectedGoals.length >= 2
                                    ? Colors.orange
                                    : Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Selecciona al menos 2 objetivos',
                        style: TextStyle(
                          color: selectedGoals.length >= 2
                              ? Colors.green
                              : Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 16),

                      ...goals.map((goal) {
                        final isSelected = selectedGoals.contains(
                          goal['key'],
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  // Deseleccionar si ya está seleccionado
                                  selectedGoals.remove(goal['key']);
                                } else {
                                  // Seleccionar (permitir múltiples)
                                  selectedGoals.add(goal['key']);
                                }
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.grey[900],
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.white24,
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
                                      color: Colors.orange.withOpacity(0.2),
                                    ),
                                    child: Icon(
                                      goal['icon'],
                                      color: Colors.orange,
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
                                          goal['title'],
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
                                          goal['description'],
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
                        );
                      }).toList(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Botón Continuar
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      selectedGoals.length >= 2
                          ? Colors.orange.shade400
                          : Colors.grey.shade600,
                      selectedGoals.length >= 2
                          ? Colors.orange.shade600
                          : Colors.grey.shade800,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton(
                  onPressed: selectedGoals.length >= 2 ? _finishSetup : null,
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
    );
  }
}
