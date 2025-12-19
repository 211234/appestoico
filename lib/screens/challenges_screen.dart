import 'package:flutter/material.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
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
                  'Desafíos Estoica',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fortalece tu carácter a través de la práctica',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),

                // Estadísticas
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.2),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: const [
                            Text(
                              '1250',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'PUNTOS TOTALES',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 50, color: Colors.white30),
                      Expanded(
                        child: Column(
                          children: const [
                            Text(
                              '0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'COMPLETADOS',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Desafíos Activos
                Row(
                  children: const [
                    Icon(Icons.bolt, color: Colors.blue, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Desafíos Activos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildChallengeCard(
                  icon: Icons.self_improvement,
                  iconColor: Colors.green,
                  title: 'Dominio del Temperamento',
                  subtitle: 'En progreso',
                  description:
                      'Mantén la calma en situaciones estresantes durante 14 días consecutivos.',
                  progress: 0.21,
                  progressText: 'Día 3 de 14',
                  points: 250,
                  isActive: true,
                ),

                const SizedBox(height: 30),

                // Nuevos Desafíos
                Row(
                  children: const [
                    Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.white70,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Nuevos Desafíos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildChallengeCard(
                  icon: Icons.nightlight_round,
                  iconColor: Colors.orange,
                  title: 'Dominio del Temperamento',
                  subtitle: 'Disponible',
                  description:
                      'Dedica 10 minutos cada noche a reflexionar sobre tus acciones.',
                  timeText: '7 días',
                  points: 100,
                  isActive: false,
                ),

                const SizedBox(height: 16),

                _buildChallengeCard(
                  icon: Icons.volunteer_activism,
                  iconColor: Colors.purple,
                  title: 'Dominio del Temperamento',
                  subtitle: 'Disponible',
                  description:
                      'Realiza un acto de bondad desinteresada cada día.',
                  timeText: '30 días',
                  points: 25,
                  isActive: false,
                ),

                const SizedBox(height: 16),

                _buildChallengeCard(
                  icon: Icons.radio_button_checked,
                  iconColor: Colors.blue,
                  title: 'Dominio del Temperamento',
                  subtitle: 'Disponible',
                  description:
                      'No te quejes de nada ni del clima por 24 horas.',
                  timeText: '1 días',
                  points: 50,
                  isActive: false,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
    double? progress,
    String? progressText,
    String? timeText,
    required int points,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.blue.withOpacity(0.5) : Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$points pts',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Progreso o tiempo
          if (isActive && progress != null) ...[
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white54, size: 16),
                const SizedBox(width: 4),
                Text(
                  progressText ?? '',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 6,
              ),
            ),
          ] else if (!isActive && timeText != null) ...[
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.white54, size: 16),
                SizedBox(width: 4),
                Text(
                  timeText,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Realizar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
