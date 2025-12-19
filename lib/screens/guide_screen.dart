import 'package:flutter/material.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({Key? key}) : super(key: key);

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Título
                const Text(
                  'Guía Estoica',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu ruta completa hacia la maestría estoica',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),

                // Progreso General
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.3),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Progreso general',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        '50%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.grey[900],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.purple,
                    ),
                    minHeight: 8,
                  ),
                ),

                const SizedBox(height: 40),

                // Lecciones
                _buildLessonCard(
                  number: '1',
                  isCompleted: true,
                  icon: Icons.play_circle_outline,
                  type: 'VIDEO',
                  duration: '5 MIN',
                  title: 'Introducción al Estoicismo',
                  description:
                      'Video introductorio sobre los principios fundamentales.',
                  buttonText: 'Repasar lección',
                  buttonColor: Colors.grey[700]!,
                ),

                const SizedBox(height: 16),

                _buildLessonCard(
                  number: '2',
                  isCompleted: true,
                  icon: Icons.article_outlined,
                  type: 'ARTÍCULO',
                  duration: '10 MIN',
                  title: 'Los Tres Pilares',
                  description: 'Física, Lógica y Ética estoica explicadas.',
                  buttonText: 'Repasar lección',
                  buttonColor: Colors.grey[700]!,
                ),

                const SizedBox(height: 16),

                _buildLessonCard(
                  number: '3',
                  isCompleted: false,
                  icon: Icons.play_circle_outline,
                  type: 'VIDEO',
                  duration: '8 MIN',
                  title: 'La Dicotomía del Control',
                  description: 'Aprende a diferenciar lo que depende de ti.',
                  buttonText: 'Comenzar lección',
                  buttonColor: Colors.blue,
                  isActive: true,
                ),

                const SizedBox(height: 16),

                _buildLessonCard(
                  number: '4',
                  isCompleted: false,
                  isLocked: true,
                  icon: Icons.menu_book,
                  type: 'LIBRO',
                  duration: '15 MIN',
                  title: 'Meditaciones de Marco Aurelio',
                  description: 'Lecturas esenciales para principiantes.',
                  buttonText: 'Ver',
                  buttonColor: Colors.orange,
                ),

                const SizedBox(height: 16),

                _buildLessonCard(
                  number: '5',
                  isCompleted: false,
                  isLocked: true,
                  icon: Icons.play_circle_outline,
                  type: 'VIDEO',
                  duration: '15 MIN',
                  title: 'La filosofía del estoicismo',
                  description: 'Cual es la vida que podemos vivir',
                  buttonText: 'Ver',
                  buttonColor: Colors.orange,
                ),

                const SizedBox(height: 16),

                _buildLessonCard(
                  number: '6',
                  isCompleted: false,
                  isLocked: true,
                  icon: Icons.play_circle_outline,
                  type: 'VIDEO',
                  duration: '15 MIN',
                  title: 'Tutoría al estoicismo',
                  description: 'Lecturas esenciales para principiantes.',
                  buttonText: 'Ver',
                  buttonColor: Colors.orange,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard({
    required String number,
    required bool isCompleted,
    bool isLocked = false,
    bool isActive = false,
    required IconData icon,
    required String type,
    required String duration,
    required String title,
    required String description,
    required String buttonText,
    required Color buttonColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Colors.blue
              : isCompleted
              ? Colors.green.withOpacity(0.5)
              : Colors.grey[800]!,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número/Estado
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : isLocked
                  ? Colors.grey[800]
                  : Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : isLocked
                  ? const Icon(Icons.lock, color: Colors.white54, size: 20)
                  : Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo y duración
                Row(
                  children: [
                    Icon(icon, color: Colors.blue, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$type - $duration',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (isCompleted)
                      const Text(
                        'Completado',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Título
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Descripción
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),

                // Botón
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLocked ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      disabledBackgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonText,
                          style: TextStyle(
                            color: isLocked ? Colors.white54 : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isLocked) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
