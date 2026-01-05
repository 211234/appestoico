import 'package:flutter/material.dart';
import '../widgets/sweet_alert.dart';
import '../services/quiz_service.dart';
import '../services/api_service.dart';
import '../main.dart';

class Quiz5Screen extends StatefulWidget {
  const Quiz5Screen({Key? key}) : super(key: key);

  @override
  State<Quiz5Screen> createState() => _Quiz5ScreenState();
}

class _Quiz5ScreenState extends State<Quiz5Screen> {
  String? selectedLevel;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> knowledgeLevels = [
    {
      'level': 'principiante',
      'title': 'Principiante',
      'description':
          'No sé casi nada del tema o conozco solo lo superficial del Estoicismo.',
      'icon': Icons.brightness_5,
      'color': Colors.blue,
    },
    {
      'level': 'basico_intermedio',
      'title': 'Básico Intermedio',
      'description':
          'Tengo conocimientos básicos y estoy empezando a profundizar en el Estoicismo.',
      'icon': Icons.brightness_6,
      'color': Colors.lightBlue,
    },
    {
      'level': 'intermedio',
      'title': 'Intermedio',
      'description':
          'Tengo una buena comprensión del Estoicismo y sus principios fundamentales.',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
    },
    {
      'level': 'intermedio_avanzado',
      'title': 'Intermedio Avanzado',
      'description':
          'Tengo un conocimiento sólido y aplico consistentemente los principios estoicos.',
      'icon': Icons.wb_sunny_rounded,
      'color': Colors.deepOrange,
    },
    {
      'level': 'avanzado',
      'title': 'Avanzado',
      'description':
          'Estoy muy bien versado en el Estoicismo y lo practico diariamente.',
      'icon': Icons.wb_sunny_outlined,
      'color': Colors.amber,
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
    if (quiz.isQuiz5Complete()) {
      setState(() {
        selectedLevel = quiz.stoicLevel;
      });
    }
  }

  void _finishSetup() async {
    if (selectedLevel == null) {
      SweetAlert.showError(
        context: context,
        title: 'Selección requerida',
        message: 'Por favor selecciona tu nivel de conocimiento del Estoicismo',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Guardar el nivel seleccionado en QuizService (esto ya carga los datos existentes)
    await QuizService.updateQuiz5(stoicLevel: selectedLevel!);

    // Obtener todos los datos del quiz
    final quiz = QuizService.currentQuiz;

    // Validar que el quiz esté completo
    if (!quiz.isComplete()) {
      setState(() {
        _isSubmitting = false;
      });
      
      SweetAlert.showError(
        context: context,
        title: 'Quiz incompleto',
        message: 'Por favor completa todas las secciones del quiz',
      );
      return;
    }

    // Enviar el quiz al servidor
    final result = await ApiService.submitQuiz(
      ageRange: quiz.ageRange!,
      gender: quiz.gender!,
      country: quiz.country!,
      religiousBelief: quiz.religiousBelief!,
      spiritualPracticeLevel: quiz.spiritualPracticeLevel!,
      spiritualPracticeFrequency: quiz.spiritualPracticeFrequency!,
      dailyChallenges: quiz.dailyChallenges,
      stoicPaths: quiz.stoicPaths,
      stoicLevel: quiz.stoicLevel,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (result['success'] == true) {
      // Limpiar el quiz después de enviar exitosamente
      QuizService.clearQuiz();

      SweetAlert.showSuccess(
        context: context,
        title: 'Perfil completado exitosamente',
        message: '"Has dado el primer paso hacia el dominio de ti mismo."',
        backgroundColor: const Color(0xFF102110),
      ).then((_) {
        // Navegar al HomePage y luego seleccionar la pestaña de Perfil (índice 3)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomePage(initialTabIndex: 3),
          ),
          (route) => false,
        );
      });
    } else {
      SweetAlert.showError(
        context: context,
        title: 'Error al guardar',
        message: result['message'] ?? 'No se pudo guardar tu perfil',
      );
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
                  'Paso 5 de 5',
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
                child: const Icon(Icons.school, color: Colors.white, size: 40),
              ),

              const SizedBox(height: 40),

              // Título
              const Text(
                'Tu Nivel de Conocimiento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                '¿Qué tanto sabes del Estoicismo?',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: knowledgeLevels.map((levelData) {
                      final isSelected = selectedLevel == levelData['level'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLevel = levelData['level'];
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
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
                                // Icono
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.orange.withOpacity(0.3)
                                        : Colors.grey[800],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    levelData['icon'],
                                    color: isSelected
                                        ? Colors.orange
                                        : Colors.white60,
                                    size: 30,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Texto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        levelData['title'],
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.orange
                                              : Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        levelData['description'],
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Indicador de selección
                                if (isSelected)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón de continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _finishSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Finalizar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _goBackToHome,
                child: const Text(
                  'Omitir por ahora',
                  style: TextStyle(color: Colors.white60),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
