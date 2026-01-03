import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_spinner.dart';
import '../widgets/sweet_alert.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseId;
  final String name;
  final String level;
  final String objective;
  final String? instructions;
  final String? duration;
  final String? reflection;
  final String? source;
  final Color levelColor;
  final IconData levelIcon;
  final VoidCallback? onCompleted;

  const ExerciseDetailScreen({
    Key? key,
    required this.exerciseId,
    required this.name,
    required this.level,
    required this.objective,
    this.instructions,
    this.duration,
    this.reflection,
    this.source,
    required this.levelColor,
    required this.levelIcon,
    this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (BuildContext sheetContext, scrollController) {
        final bottomPadding = MediaQuery.of(sheetContext).padding.bottom;
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: 24 + bottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con icono
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: levelColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(levelIcon, color: levelColor, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: levelColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    level.toUpperCase(),
                                    style: TextStyle(
                                      color: levelColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Título del ejercicio
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Objetivo
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.track_changes,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Objetivo',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              objective,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Instrucciones
                      if (instructions != null && instructions!.isNotEmpty) ...[
                        _buildInfoSection(
                          icon: Icons.list_alt,
                          title: 'Instrucciones',
                          content: instructions!,
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Duración
                      if (duration != null && duration!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Duración',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      duration!,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Reflexión
                      if (reflection != null && reflection!.isNotEmpty) ...[
                        _buildInfoSection(
                          icon: Icons.psychology,
                          title: 'Pregunta de Reflexión',
                          content: reflection!,
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Fuente
                      if (source != null && source!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.book,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Fuente',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      source!,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      const SizedBox(height: 32),
                      // Botón de completar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _completeChallenge(context);
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Completar Desafío'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: levelColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      // Espacio adicional al final para evitar que el botón quede tapado
                      SizedBox(height: bottomPadding),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
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
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeChallenge(BuildContext context) async {
    // Guardar Navigator ANTES de operaciones asíncronas
    final navigator = Navigator.of(context);
    
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CustomSpinner(size: 50),
              SizedBox(height: 16),
              Text(
                'Completando desafío...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Paso 1: Completar el ejercicio (esta es la llamada crítica)
      http.StreamedResponse? completeExerciseResponse;
      try {
        final request = http.Request(
          'POST',
          Uri.parse('https://web.estoico.app/ia/generate/exercises/$exerciseId/complete'),
        );
        request.headers['Content-Type'] = 'application/json';
        request.headers['Authorization'] = 'Bearer $token';
        
        completeExerciseResponse = await request.send()
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        // Usar navigator guardado en lugar de context
        try {
          navigator.pop();
        } catch (navError) {
          // Si falla, intentar con context si aún está montado
          if (context.mounted) {
            try {
              Navigator.of(context).pop();
            } catch (e2) {
              // Ignorar si ambos fallan
            }
          }
        }
        if (context.mounted) {
          SweetAlert.showError(
            context: context,
            title: 'Error',
            message: 'No se pudo completar el ejercicio: $e',
          );
        }
        return;
      }

      // Cerrar loading INMEDIATAMENTE después de recibir la respuesta (antes de procesar)
      // CERRAR DIALOG usando navigator guardado (no depende de context.mounted)
      try {
        navigator.pop();
      } catch (navError) {
        // Intentar con context si aún está montado
        if (context.mounted) {
          try {
            Navigator.of(context).pop();
          } catch (e2) {
            // Ignorar si ambos fallan
          }
        }
      }

      // Procesar respuesta del ejercicio EN BACKGROUND (no bloquea UI)
      _processExerciseResponse(completeExerciseResponse, context);

    } catch (e) {
      // Cerrar loading si aún está abierto
      try {
        navigator.pop();
      } catch (navError) {
        if (context.mounted) {
          try {
            Navigator.of(context).pop();
          } catch (e2) {
            // Ignorar si ambos fallan
          }
        }
      }

      if (context.mounted) {
        SweetAlert.showError(
          context: context,
          title: 'Error',
          message: 'No se pudo completar el desafío: $e',
        );
      }
    }
  }

  Future<void> _processExerciseResponse(http.StreamedResponse response, BuildContext context) async {
    try {
      // Procesar respuesta del ejercicio
      if (response.statusCode != 200) {
        final responseBody = await response.stream.bytesToString();
        final errorData = json.decode(responseBody);
        if (context.mounted) {
          SweetAlert.showError(
            context: context,
            title: 'Error',
            message: errorData['message'] ?? 'No se pudo completar el ejercicio',
          );
        }
        return;
      }

      final responseBody = await response.stream.bytesToString();
      final completeData = json.decode(responseBody);
      print('✅ Ejercicio completado: $completeData');

      // Obtener token para guardar puntos
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Paso 2: Guardar puntos usando el exercise_id del ejercicio completado
      // Usamos el exercise_id en lugar del nombre para evitar duplicados
      final completedExerciseId = completeData['exercise_id'] ?? exerciseId;
      _saveChallengePoints(token, completedExerciseId, name, level, objective).then((result) {
        // Ejercicio completado exitosamente (ya sea que el segundo POST funcione o falle por duplicado)
        // El primer POST ya marcó el ejercicio como completado, así que siempre llamamos al callback
        // Primero eliminar el ejercicio de la lista
        if (onCompleted != null) {
          onCompleted!();
        }
        
        // Cerrar el modal para que el usuario vea que el ejercicio desapareció de la lista
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        
        if (result['success'] == true && context.mounted) {
          final data = result['data'];
          final levelChanged = data['level_changed'] ?? false;
          final totalPoints = data['total_points'] ?? 0;
          final currentLevel = data['current_level_label'] ?? 'Principiante';

          if (levelChanged) {
            _showLevelUpDialog(
              context: context,
              message: result['message'],
              newLevel: currentLevel,
              totalPoints: totalPoints,
              progress: data['progress'],
            );
          } else {
            String message = '${result['message']}\n\nPuntos totales: $totalPoints';
            
            if (completeData['new_exercise'] != null) {
              message += '\n\n¡Se ha generado un nuevo ejercicio para ti!';
            }
            
            SweetAlert.showSuccess(
              context: context,
              title: '¡Desafío Completado!',
              message: message,
              backgroundColor: const Color(0xFF102110),
            );
          }
        } else {
          // Si falla porque ya fue completado, el primer POST ya guardó los puntos
          // El backend está rechazando porque detecta duplicado por nombre/nivel/objetivo
          // pero el primer POST ya marcó el ejercicio como completado y guardó los puntos
          String errorMessage = result['message'] ?? '';
          bool alreadyCompleted = errorMessage.contains('Ya has completado') || 
                                 errorMessage.contains('ya completado') ||
                                 errorMessage.contains('anteriormente');
          
          if (context.mounted) {
            if (alreadyCompleted) {
              // El ejercicio ya fue completado, los puntos ya están guardados por el primer POST
              // El segundo POST es redundante cuando el backend detecta duplicado
              // Mostrar mensaje de éxito y el progreso se actualizará cuando el usuario vaya al perfil
              String message = 'Ejercicio completado exitosamente.\n\nLos puntos han sido registrados.';
              if (completeData['new_exercise'] != null) {
                message += '\n\n¡Se ha generado un nuevo ejercicio para ti!';
              }
              SweetAlert.showSuccess(
                context: context,
                title: '¡Desafío Completado!',
                message: message,
                backgroundColor: const Color(0xFF102110),
              );
            } else {
              // Otro tipo de error
              SweetAlert.showSuccess(
                context: context,
                title: '¡Desafío Completado!',
                message: 'El ejercicio se completó exitosamente. Los puntos se guardarán en breve.',
                backgroundColor: const Color(0xFF102110),
              );
            }
          }
        }
      }).catchError((error) {
        print('⚠️ Error al guardar puntos (no crítico): $error');
        // Aún así, el ejercicio fue completado por el primer POST, así que llamamos al callback
        // Primero eliminar el ejercicio de la lista
        if (onCompleted != null) {
          onCompleted!();
        }
        // Cerrar el modal para que el usuario vea que el ejercicio desapareció de la lista
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        // Si falla, mostrar mensaje de éxito básico
        if (context.mounted) {
          SweetAlert.showSuccess(
            context: context,
            title: '¡Desafío Completado!',
            message: 'El ejercicio se completó exitosamente.',
            backgroundColor: const Color(0xFF102110),
          );
        }
      });
    } catch (e) {
      if (context.mounted) {
        SweetAlert.showError(
          context: context,
          title: 'Error',
          message: 'Error al procesar la respuesta: $e',
        );
      }
    }
  }

  Future<Map<String, dynamic>> _saveChallengePoints(
    String token,
    String exerciseId,
    String exerciseName,
    String exerciseLevel,
    String exerciseObjective,
  ) async {
    try {
      print('💾 Guardando puntos: exerciseId=$exerciseId, name=$exerciseName, level=$exerciseLevel, objective=$exerciseObjective');
      
      // Intentar primero con exercise_id si el backend lo acepta
      Map<String, dynamic> requestBody = {
        'exercise_id': exerciseId,
        'name': exerciseName,
        'level': exerciseLevel,
        'objective': exerciseObjective,
      };
      
      final response = await http.post(
        Uri.parse('https://web.estoico.app/api/challenges/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 10));

      print('💾 Respuesta guardar puntos: statusCode=${response.statusCode}, body=${response.body}');
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 201 && responseData['success'] == true) {
        print('✅ Puntos guardados exitosamente: ${responseData['data']?['total_points']} puntos totales');
        return responseData;
      } else {
        print('❌ Error al guardar puntos: ${responseData['message']}');
        return {'success': false, 'message': responseData['message'] ?? 'Error desconocido'};
      }
    } catch (e) {
      print('❌ Excepción al guardar puntos: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  void _showLevelUpDialog({
    required BuildContext context,
    required String message,
    required String newLevel,
    required int totalPoints,
    required Map<String, dynamic> progress,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.9),
                  Colors.deepOrange.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono animado
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡Felicidades!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        newLevel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Puntos totales: $totalPoints',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void show({
    required BuildContext context,
    required String exerciseId,
    required String name,
    required String level,
    required String objective,
    String? instructions,
    String? duration,
    String? reflection,
    String? source,
    required Color levelColor,
    required IconData levelIcon,
    VoidCallback? onCompleted,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ExerciseDetailScreen(
          exerciseId: exerciseId,
          name: name,
          level: level,
          objective: objective,
          instructions: instructions,
          duration: duration,
          reflection: reflection,
          source: source,
          levelColor: levelColor,
          levelIcon: levelIcon,
          onCompleted: onCompleted,
        );
      },
    );
  }
}
