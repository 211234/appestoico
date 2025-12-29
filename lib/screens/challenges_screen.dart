import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/custom_spinner.dart';
import '../services/api_service.dart';
import '../widgets/sweet_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exercise_detail_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  bool _isLoading = true;
  bool _isPremium = false;
  bool _isGenerating = false;
  String _statusMessage = '';
  List<Map<String, dynamic>> _exercises = [];
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPremiumStatus() async {
    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.getUserProfile();

    if (result['success'] && result['data'] != null) {
      setState(() {
        _isPremium = result['data']['isPremium'] == true;
        _isLoading = false;
      });

      // Si es premium, generar ejercicios automáticamente
      if (_isPremium) {
        _generateExercises();
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateExercises() async {
    setState(() {
      _isGenerating = true;
      _statusMessage = 'Iniciando generación...';
      _exercises.clear();
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final request = http.Request(
        'GET',
        Uri.parse('https://web.estoico.app/ia/generate/exercises/stream'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();

      if (response.statusCode == 200) {
        final stream = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        _streamSubscription = stream.listen(
          (line) {
            if (line.trim().isEmpty) return;

            try {
              final data = json.decode(line);

              if (data['status'] != null) {
                setState(() {
                  _statusMessage = data['status']['message'] ?? '';
                });
              } else if (data['profile'] != null) {
                setState(() {
                  _statusMessage =
                      'Perfil: ${data['profile']['summary'] ?? ''}';
                });
              } else if (data['exercise'] != null) {
                setState(() {
                  _exercises.add({
                    'name': data['exercise']['name'] ?? 'Sin nombre',
                    'level': data['exercise']['level'] ?? 'principiante',
                    'objective': data['exercise']['objective'] ?? '',
                  });
                });
              } else if (data['message'] != null &&
                  data['message'].toString().contains('completados')) {
                setState(() {
                  _isGenerating = false;
                  _statusMessage = data['message'];
                });
              }
            } catch (e) {
              print('Error parsing line: $line, error: $e');
            }
          },
          onError: (error) {
            setState(() {
              _isGenerating = false;
              _statusMessage = 'Error al generar ejercicios';
            });
            if (mounted) {
              SweetAlert.showError(
                context: context,
                title: 'Error',
                message: 'No se pudieron generar los ejercicios',
              );
            }
          },
          onDone: () {
            setState(() {
              _isGenerating = false;
            });
          },
        );
      } else {
        setState(() {
          _isGenerating = false;
          _statusMessage = 'Error al conectar con el servidor';
        });
        if (mounted) {
          SweetAlert.showError(
            context: context,
            title: 'Error',
            message: 'No se pudo conectar al servidor',
          );
        }
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _statusMessage = 'Error: $e';
      });
      if (mounted) {
        SweetAlert.showError(
          context: context,
          title: 'Error',
          message: 'Ocurrió un error inesperado',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CustomSpinner(size: 60)),
      );
    }

    if (!_isPremium) {
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
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.2),
                          Colors.orange.withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.orange,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Vista de Hombre Estoico Premium',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Solo después de pagar el premium se generarán los desafíos personalizados basados en tu perfil estoico',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.orange,
                          size: 32,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Con Premium obtendrás:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        _BenefitItem(
                          icon: Icons.psychology,
                          text: 'Ejercicios personalizados con IA',
                        ),
                        SizedBox(height: 12),
                        _BenefitItem(
                          icon: Icons.track_changes,
                          text: 'Desafíos adaptativos a tu nivel',
                        ),
                        SizedBox(height: 12),
                        _BenefitItem(
                          icon: Icons.library_books,
                          text: 'Contenido exclusivo de estoicismo',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Desafíos Estoicos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ejercicios personalizados generados con IA',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              if (_isGenerating) ...[
                Center(
                  child: Column(
                    children: [
                      const CustomSpinner(size: 60),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],

              if (_exercises.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Ejercicios Generados (${_exercises.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              Expanded(
                child: _exercises.isEmpty && !_isGenerating
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.white54,
                              size: 80,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Generando tus ejercicios...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Esto puede tomar unos segundos',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _exercises[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildExerciseCard(
                              index: index + 1,
                              name: exercise['name'],
                              level: exercise['level'],
                              objective: exercise['objective'],
                            ),
                          );
                        },
                      ),
              ),

              if (!_isGenerating && _exercises.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _generateExercises,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Regenerar Ejercicios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard({
    required int index,
    required String name,
    required String level,
    required String objective,
  }) {
    Color levelColor;
    IconData levelIcon;

    switch (level.toLowerCase()) {
      case 'principiante':
        levelColor = Colors.green;
        levelIcon = Icons.emoji_events;
        break;
      case 'intermedio':
        levelColor = Colors.orange;
        levelIcon = Icons.military_tech;
        break;
      case 'avanzado':
        levelColor = Colors.red;
        levelIcon = Icons.workspace_premium;
        break;
      default:
        levelColor = Colors.grey;
        levelIcon = Icons.star;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: levelColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(levelIcon, color: levelColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Ejercicio $index',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            level.toUpperCase(),
                            style: TextStyle(
                              color: levelColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Colors.white54,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  objective,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ExerciseDetailScreen.show(
                  context: context,
                  name: name,
                  level: level,
                  objective: objective,
                  levelColor: levelColor,
                  levelIcon: levelIcon,
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('Ver Detalles'),
              style: ElevatedButton.styleFrom(
                backgroundColor: levelColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
