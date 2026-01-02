import 'package:flutter/material.dart';
import 'quiz3_screen.dart';
import '../services/quiz_service.dart';
import '../main.dart';

class Quiz2Screen extends StatefulWidget {
  const Quiz2Screen({Key? key}) : super(key: key);

  @override
  State<Quiz2Screen> createState() => _Quiz2ScreenState();
}

class _Quiz2ScreenState extends State<Quiz2Screen> {
  String? selectedReligion;
  String? selectedSpiritualPractice;
  String? selectedFrequency;

  final List<Map<String, dynamic>> religions = [
    {'name': 'Catolico', 'icon': Icons.add},
    {'name': 'Evangelico', 'icon': Icons.shield},
    {'name': 'Testigo de Jehova', 'icon': Icons.book},
    {'name': 'Mormon', 'icon': Icons.star},
    {'name': 'Judio', 'icon': Icons.temple_hindu},
    {'name': 'Musulman', 'icon': Icons.nightlight_round},
    {'name': 'Budista', 'icon': Icons.self_improvement},
    {'name': 'Espirituale', 'icon': Icons.auto_awesome},
    {'name': 'Otros', 'icon': Icons.help_outline},
  ];

  final List<String> practiceOptions = [
    'Muy activa',
    'Moderada',
    'Ocasional',
    'No practico',
  ];

  final List<String> frequencyOptions = [
    'Diariamente',
    'Semanalmente',
    'Ocasionalmente',
    'Nunca',
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
    if (quiz.isQuiz2Complete()) {
      setState(() {
        selectedReligion = _getReligionDisplay(quiz.religiousBelief);
        selectedSpiritualPractice = _getPracticeDisplay(
          quiz.spiritualPracticeLevel,
        );
        selectedFrequency = _getFrequencyDisplay(
          quiz.spiritualPracticeFrequency,
        );
      });
    }
  }

  // Mapeo religión: Visual → API
  String _getReligionValue(String display) {
    final map = {
      'Catolico': 'catolico',
      'Evangelico': 'evangelico',
      'Testigo de Jehova': 'testigo_de_jehova',
      'Mormon': 'mormon',
      'Judio': 'judio',
      'Musulman': 'musulman',
      'Budista': 'budista',
      'Espirituale': 'espirituales',
      'Otros': 'otros',
    };
    return map[display] ?? display.toLowerCase();
  }

  String _getReligionDisplay(String? value) {
    final map = {
      'catolico': 'Catolico',
      'evangelico': 'Evangelico',
      'testigo_de_jehova': 'Testigo de Jehova',
      'mormon': 'Mormon',
      'judio': 'Judio',
      'musulman': 'Musulman',
      'budista': 'Budista',
      'espirituales': 'Espirituale',
      'otros': 'Otros',
    };
    return map[value] ?? value ?? '';
  }

  // Mapeo práctica espiritual: Visual → API
  String _getPracticeValue(String display) {
    final map = {
      'Muy activa': 'muy_activa',
      'Moderada': 'moderada',
      'Ocasional': 'ocasional',
      'No practico': 'no_practico',
    };
    return map[display] ?? display.toLowerCase();
  }

  String _getPracticeDisplay(String? value) {
    final map = {
      'muy_activa': 'Muy activa',
      'moderada': 'Moderada',
      'ocasional': 'Ocasional',
      'no_practico': 'No practico',
    };
    return map[value] ?? value ?? '';
  }

  // Mapeo frecuencia: Visual → API
  String _getFrequencyValue(String display) {
    final map = {
      'Diariamente': 'diariamente',
      'Semanalmente': 'semanalmente',
      'Ocasionalmente': 'ocasionalmente',
      'Nunca': 'nunca',
    };
    return map[display] ?? display.toLowerCase();
  }

  String _getFrequencyDisplay(String? value) {
    final map = {
      'diariamente': 'Diariamente',
      'semanalmente': 'Semanalmente',
      'ocasionalmente': 'Ocasionalmente',
      'nunca': 'Nunca',
    };
    return map[value] ?? value ?? '';
  }

  void _continueToNext() {
    if (selectedReligion != null &&
        selectedSpiritualPractice != null &&
        selectedFrequency != null) {
      // Guardar datos en el servicio
      QuizService.updateQuiz2(
        religiousBelief: _getReligionValue(selectedReligion!),
        spiritualPracticeLevel: _getPracticeValue(selectedSpiritualPractice!),
        spiritualPracticeFrequency: _getFrequencyValue(selectedFrequency!),
      );

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Quiz3Screen()));
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
                  'Paso 2 de 5',
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
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 40),

              // Título
              const Text(
                'Espiritualidad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                'Explora tu dimensión espiritual',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pregunta sobre creencia religiosa
                      const Text(
                        '¿Cuál es tu creencia religiosa o espiritual?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Grid de religiones
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.5,
                        children: religions.map((religion) {
                          final isSelected =
                              selectedReligion == religion['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedReligion = religion['name'];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.white24,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    religion['icon'],
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    religion['name'],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),

                      // Pregunta sobre práctica espiritual con ícono
                      Row(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            '¿Qué tan activa es tu práctica espiritual?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Opciones de práctica espiritual
                      ...practiceOptions.map((practice) {
                        final isSelected =
                            selectedSpiritualPractice == practice;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSpiritualPractice = practice;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.white24,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                practice,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.black : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 32),

                      // Pregunta sobre frecuencia con ícono de montaña
                      Row(
                        children: [
                          Icon(Icons.terrain, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            '¿Con qué frecuencia practicas?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Opciones de frecuencia
                      ...frequencyOptions.map((frequency) {
                        final isSelected = selectedFrequency == frequency;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFrequency = frequency;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.white24,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                frequency,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.black : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
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
                      selectedReligion != null &&
                              selectedSpiritualPractice != null &&
                              selectedFrequency != null
                          ? Colors.orange.shade400
                          : Colors.grey.shade600,
                      selectedReligion != null &&
                              selectedSpiritualPractice != null &&
                              selectedFrequency != null
                          ? Colors.orange.shade600
                          : Colors.grey.shade800,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton(
                  onPressed: selectedReligion != null &&
                          selectedSpiritualPractice != null &&
                          selectedFrequency != null
                      ? _continueToNext
                      : null,
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
