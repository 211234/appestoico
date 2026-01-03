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

    try {
      // Primero verificar la suscripción guardada localmente
      final prefs = await SharedPreferences.getInstance();
      final subscriptionStr = prefs.getString('subscription');
      
      print('🔍 Verificando suscripción local...');
      print('🔍 subscriptionStr: ${subscriptionStr != null ? "existe" : "no existe"}');
      
      bool isPremium = false;
      
      if (subscriptionStr != null) {
        try {
          final subscription = json.decode(subscriptionStr);
          print('🔍 Suscripción local completa: $subscription');
          print('🔍 hasActiveSubscription: ${subscription['hasActiveSubscription']}');
          print('🔍 status: ${subscription['status']}');
          
          isPremium = subscription['hasActiveSubscription'] == true &&
                     subscription['status'] == 'active';
          
          print('🔍 isPremium desde suscripción local: $isPremium');
        } catch (e) {
          print('❌ Error al parsear suscripción local: $e');
          print('❌ subscriptionStr contenido: $subscriptionStr');
        }
      } else {
        print('⚠️ No hay suscripción guardada localmente. El usuario necesita hacer login nuevamente.');
      }
      
      // Si no hay suscripción local o no es premium, intentar obtenerla del servidor
      if (!isPremium) {
        print('🔍 Intentando obtener suscripción del servidor...');
        
        // Intentar obtener la suscripción directamente desde el endpoint de login o perfil
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          
          if (token != null && token.isNotEmpty) {
            // Hacer una petición directa para obtener la suscripción
            final response = await http.get(
              Uri.parse('https://web.estoico.app/api/users/me'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            ).timeout(const Duration(seconds: 10));
            
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              print('🔍 Respuesta completa del servidor: $data');
              
              // Verificar si hay información de suscripción en la respuesta
              if (data['subscription'] != null) {
                final subscription = data['subscription'];
                print('🔍 Suscripción del servidor: $subscription');
                
                // Guardar la suscripción localmente
                await prefs.setString('subscription', jsonEncode(subscription));
                
                isPremium = subscription['hasActiveSubscription'] == true &&
                           subscription['status'] == 'active';
                
                print('🔍 isPremium desde servidor: $isPremium');
              } else if (data['data'] != null && data['data']['subscription'] != null) {
                final subscription = data['data']['subscription'];
                print('🔍 Suscripción en data.subscription: $subscription');
                
                await prefs.setString('subscription', jsonEncode(subscription));
                
                isPremium = subscription['hasActiveSubscription'] == true &&
                           subscription['status'] == 'active';
                
                print('🔍 isPremium desde data.subscription: $isPremium');
              }
            }
          }
        } catch (e) {
          print('❌ Error al obtener suscripción del servidor: $e');
        }
        
        // Si aún no es premium, verificar en el perfil
        if (!isPremium) {
          final result = await ApiService.getUserProfile();
          print('🔍 Resultado getUserProfile: $result');
          
          // Verificar si hay suscripción en la respuesta de getUserProfile
          if (result['subscription'] != null) {
            final subscription = result['subscription'];
            print('🔍 Suscripción encontrada en getUserProfile: $subscription');
            
            // Guardar la suscripción localmente
            await prefs.setString('subscription', jsonEncode(subscription));
            
            isPremium = subscription['hasActiveSubscription'] == true &&
                       subscription['status'] == 'active';
            
            print('🔍 isPremium desde getUserProfile.subscription: $isPremium');
          }
          
          if (result['success'] && result['data'] != null) {
            final userData = result['data'];
            print('🔍 Datos del usuario: $userData');
            print('🔍 Claves disponibles: ${userData.keys.toList()}');
            
            // Verificar diferentes variantes del campo premium en el perfil
            if (!isPremium) {
              isPremium = userData['isPremium'] == true ||
                         userData['is_premium'] == true ||
                         userData['premium'] == true ||
                         userData['subscription_active'] == true ||
                         userData['has_premium'] == true ||
                         userData['isPremium'] == 1 ||
                         userData['is_premium'] == 1;
              
              print('🔍 isPremium desde perfil: $isPremium');
            }
          }
        }
      }
      
      print('🔍 isPremium final: $isPremium');
      
      setState(() {
        _isPremium = isPremium;
        _isLoading = false;
      });

      // Si es premium, cargar ejercicios pendientes primero
      if (_isPremium) {
        print('✅ Usuario premium detectado, cargando ejercicios pendientes...');
        _loadPendingExercises();
      } else {
        print('❌ Usuario no es premium');
        print('💡 Sugerencia: El usuario necesita hacer login nuevamente para actualizar la información de suscripción.');
      }
    } catch (e) {
      print('❌ Excepción en _checkPremiumStatus: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        SweetAlert.showError(
          context: context,
          title: 'Error',
          message: 'No se pudo verificar el estado de suscripción: $e',
        );
      }
    }
  }

  Future<void> _loadPendingExercises() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Cargando ejercicios pendientes...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://web.estoico.app/ia/generate/exercises?status=pending'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final exercises = data['exercises'] as List<dynamic>? ?? [];
        final pendingCount = data['pending_count'] ?? 0;

        setState(() {
          _exercises = exercises.map((e) => {
            'id': e['id'] ?? '',
            'name': e['name'] ?? 'Sin nombre',
            'level': e['level'] ?? 'principiante',
            'objective': e['objective'] ?? '',
            'instructions': e['instructions'] ?? '',
            'duration': e['duration'] ?? '',
            'reflection': e['reflection'] ?? '',
            'source': e['source'] ?? '',
            'status': e['status'] ?? 'pending',
            'completed_at': e['completed_at'],
            'created_at': e['created_at'],
          }).toList();
          _isLoading = false;
          _statusMessage = pendingCount > 0 
            ? '$pendingCount ejercicios pendientes' 
            : 'No hay ejercicios pendientes';
        });

        // Si no hay ejercicios pendientes, generar nuevos
        if (pendingCount == 0) {
          print('📝 No hay ejercicios pendientes, generando nuevos...');
          _generateExercises();
        } else {
          print('✅ Se cargaron $pendingCount ejercicios pendientes');
        }
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error al cargar ejercicios';
        });
      }
    } catch (e) {
      print('❌ Error al cargar ejercicios pendientes: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error al cargar ejercicios';
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

      print('🔍 Token encontrado: ${token.isNotEmpty ? 'Sí' : 'No'}');
      print('🔍 Longitud del token: ${token.length}');

      if (token.isEmpty) {
        setState(() {
          _isGenerating = false;
          _statusMessage = 'No se encontró el token de autenticación';
        });
        if (mounted) {
          SweetAlert.showError(
            context: context,
            title: 'Error',
            message: 'Por favor, inicia sesión nuevamente',
          );
        }
        return;
      }

      final url = 'https://web.estoico.app/ia/generate/exercises/stream';
      print('🔍 Llamando a: $url');
      
      final request = http.Request(
        'GET',
        Uri.parse(url),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'application/json';

      print('🔍 Enviando petición...');
      final response = await request.send();
      print('🔍 Respuesta recibida: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Stream iniciado correctamente');
        final stream = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        String? currentEventType;
        
        _streamSubscription = stream.listen(
          (line) {
            if (line.trim().isEmpty) return;

            print('📥 Línea recibida: $line');

            try {
              final trimmedLine = line.trim();
              
              // Manejar formato Server-Sent Events (SSE)
              if (trimmedLine.startsWith('event:')) {
                // Esta es una línea de tipo de evento
                currentEventType = trimmedLine.substring(6).trim();
                print('📌 Tipo de evento: $currentEventType');
                return;
              }
              
              if (trimmedLine.startsWith('data:')) {
                // Esta es una línea de datos
                String jsonStr = trimmedLine.substring(5).trim();
                
                if (jsonStr.isEmpty) return;
                
                final data = json.decode(jsonStr);
                print('📦 Datos parseados: $data');
                print('📌 Evento actual: $currentEventType');

                // Procesar según el tipo de evento - PRIORIDAD: ejercicio primero
                if (currentEventType == 'exercise' || 
                    (data.containsKey('name') && data.containsKey('level') && data.containsKey('objective'))) {
                  // Es un ejercicio completo
                  print('💪 Ejercicio recibido: $data');
                  setState(() {
                    _exercises.add({
                      'id': data['id'] ?? '',
                      'name': data['name'] ?? 'Sin nombre',
                      'level': data['level'] ?? 'principiante',
                      'objective': data['objective'] ?? '',
                      'instructions': data['instructions'] ?? '',
                      'duration': data['duration'] ?? '',
                      'reflection': data['reflection'] ?? '',
                      'source': data['source'] ?? '',
                      'status': data['status'] ?? 'pending',
                      'completed_at': data['completed_at'],
                      'created_at': data['created_at'],
                      'index': data['index'] ?? _exercises.length + 1,
                      'total': data['total'] ?? _exercises.length,
                    });
                    _statusMessage = 'Ejercicio ${data['index'] ?? _exercises.length} de ${data['total'] ?? _exercises.length} generado';
                  });
                  print('✅ Ejercicio agregado. Total: ${_exercises.length}');
                } else if (currentEventType == 'complete' || 
                          (data['message'] != null && data['message'].toString().contains('completados'))) {
                  print('✅ Generación completada');
                  setState(() {
                    _isGenerating = false;
                    _statusMessage = data['message'] ?? 'Ejercicios generados';
                  });
                } else if (currentEventType == 'profile' || data['summary'] != null) {
                  print('👤 Perfil recibido: $data');
                  setState(() {
                    _statusMessage = 'Analizando perfil: ${data['summary'] ?? ''}';
                  });
                } else if (currentEventType == 'status' || data['message'] != null) {
                  final message = data['message'] ?? '';
                  print('💬 Mensaje de status: $message');
                  setState(() {
                    _statusMessage = message;
                  });
                  
                  // Verificar si es mensaje de finalización
                  if (message.contains('completados') || 
                      message.contains('completado') ||
                      message.contains('finalizado')) {
                    setState(() {
                      _isGenerating = false;
                    });
                  }
                } else if (data['error'] != null) {
                  print('❌ Error en stream: ${data['error']}');
                  setState(() {
                    _isGenerating = false;
                    _statusMessage = 'Error: ${data['error']}';
                  });
                } else {
                  print('⚠️ Tipo de dato desconocido. Evento: $currentEventType, Claves: ${data.keys.toList()}');
                }
                
                // Resetear el tipo de evento después de procesar
                currentEventType = null;
              } else {
                // Formato antiguo: intentar parsear directamente como JSON
                String cleanLine = trimmedLine;
                
                // Si la línea empieza con un número seguido de espacio o llave, extraer solo el JSON
                final jsonMatch = RegExp(r'\{.*\}').firstMatch(cleanLine);
                if (jsonMatch != null) {
                  cleanLine = jsonMatch.group(0)!;
                }
                
                // Si aún no es JSON válido, intentar encontrar el JSON después de espacios/números
                if (!cleanLine.startsWith('{') && !cleanLine.startsWith('[')) {
                  final jsonStart = cleanLine.indexOf('{');
                  if (jsonStart != -1) {
                    cleanLine = cleanLine.substring(jsonStart);
                  } else {
                    return; // No es JSON válido
                  }
                }
                
                final data = json.decode(cleanLine);
                print('📦 Datos parseados (formato antiguo): $data');
                
                // Manejar formato antiguo
                if (data['exercise'] != null) {
                  final exercise = data['exercise'];
                  print('💪 Ejercicio recibido (formato antiguo): $exercise');
                  setState(() {
                    _exercises.add({
                      'id': exercise['id'] ?? '',
                      'name': exercise['name'] ?? 'Sin nombre',
                      'level': exercise['level'] ?? 'principiante',
                      'objective': exercise['objective'] ?? '',
                      'instructions': exercise['instructions'] ?? '',
                      'duration': exercise['duration'] ?? '',
                      'reflection': exercise['reflection'] ?? '',
                      'source': exercise['source'] ?? '',
                      'status': exercise['status'] ?? 'pending',
                      'completed_at': exercise['completed_at'],
                      'created_at': exercise['created_at'],
                      'index': exercise['index'] ?? _exercises.length + 1,
                      'total': exercise['total'] ?? _exercises.length,
                    });
                    _statusMessage = 'Ejercicio ${exercise['index'] ?? _exercises.length} de ${exercise['total'] ?? _exercises.length} generado';
                  });
                  print('✅ Ejercicio agregado. Total: ${_exercises.length}');
                }
              }
            } catch (e) {
              print('❌ Error parsing line: $line, error: $e');
              // Continuar procesando aunque haya un error en una línea
            }
          },
          onError: (error) {
            print('❌ Error en stream: $error');
            setState(() {
              _isGenerating = false;
              _statusMessage = 'Error al generar ejercicios';
            });
            if (mounted) {
              SweetAlert.showError(
                context: context,
                title: 'Error',
                message: 'No se pudieron generar los ejercicios: ${error.toString()}',
              );
            }
          },
          onDone: () {
            print('✅ Stream completado. Ejercicios generados: ${_exercises.length}');
            setState(() {
              _isGenerating = false;
              if (_statusMessage.isEmpty) {
                _statusMessage = _exercises.isEmpty 
                    ? 'No se generaron ejercicios' 
                    : '${_exercises.length} ejercicios generados';
              }
            });
          },
        );
      } else if (response.statusCode == 401) {
        setState(() {
          _isGenerating = false;
          _statusMessage = 'No autorizado. Verifica tu suscripción.';
        });
        if (mounted) {
          SweetAlert.showError(
            context: context,
            title: 'Error de autenticación',
            message: 'Tu sesión ha expirado o no tienes una suscripción activa',
          );
        }
      } else {
        setState(() {
          _isGenerating = false;
          _statusMessage = 'Error al conectar con el servidor (${response.statusCode})';
        });
        if (mounted) {
          SweetAlert.showError(
            context: context,
            title: 'Error',
            message: 'No se pudo conectar al servidor. Código: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _statusMessage = 'Error: ${e.toString()}';
      });
      if (mounted) {
        SweetAlert.showError(
          context: context,
          title: 'Error',
          message: 'Ocurrió un error inesperado: ${e.toString()}',
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
              Row(
                children: [
                  // Logo circular (similar a la referencia)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          Colors.blue.shade300,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nuevos Desafíos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Ejercicios personalizados generados con IA',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Mostrar estado de generación
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
                          _statusMessage.isNotEmpty 
                              ? _statusMessage 
                              : 'Generando desafíos...',
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

              // Mostrar ejercicios generados
              if (_exercises.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Ejercicios Pendientes (${_exercises.length})',
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

              // Lista de ejercicios o mensaje vacío
              Expanded(
                child: _exercises.isEmpty && !_isGenerating
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Colors.white54,
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _statusMessage.isNotEmpty 
                                  ? _statusMessage 
                                  : 'No hay ejercicios generados',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Presiona el botón para generar nuevos desafíos',
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
                              exerciseId: exercise['id'] ?? '',
                              index: exercise['index'] ?? index + 1,
                              name: exercise['name'] ?? 'Sin nombre',
                              level: exercise['level'] ?? 'principiante',
                              objective: exercise['objective'] ?? '',
                              instructions: exercise['instructions'] ?? '',
                              duration: exercise['duration'] ?? '',
                              reflection: exercise['reflection'] ?? '',
                              source: exercise['source'] ?? '',
                              status: exercise['status'] ?? 'pending',
                              onCompleted: () {
                                // Eliminar el ejercicio de la lista cuando se complete
                                setState(() {
                                  _exercises.removeWhere((e) => e['id'] == exercise['id']);
                                  
                                  // Si era el último ejercicio, generar nuevos
                                  if (_exercises.isEmpty) {
                                    print('🎯 Último ejercicio completado, generando nuevos ejercicios...');
                                    _generateExercises();
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),


              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard({
    required String exerciseId,
    required int index,
    required String name,
    required String level,
    required String objective,
    String? instructions,
    String? duration,
    String? reflection,
    String? source,
    String? status,
    VoidCallback? onCompleted,
  }) {
    // Colores para los iconos circulares según el índice
    final List<List<Color>> iconColors = [
      [Colors.orange.shade300, Colors.orange.shade700, Colors.brown.shade700],
      [Colors.purple.shade300, Colors.purple.shade600, Colors.blue.shade700],
      [Colors.blue.shade300, Colors.blue.shade600, Colors.teal.shade700],
      [Colors.green.shade300, Colors.green.shade600, Colors.teal.shade600],
      [Colors.red.shade300, Colors.red.shade600, Colors.pink.shade700],
    ];
    
    final colors = iconColors[index % iconColors.length];
    
    // Cada ejercicio vale 1 punto
    const int points = 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono circular con anillos concéntricos
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors[0],
                      colors[1],
                      colors[2],
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors[0].withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Anillo exterior
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors[0].withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    // Anillo medio
                    Positioned(
                      left: 8,
                      top: 8,
                      right: 8,
                      bottom: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors[1].withOpacity(0.6),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Centro
                    Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors[2],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del desafío
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Estado del ejercicio
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (status == 'completed' 
                            ? Colors.blue 
                            : Colors.green).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (status == 'completed' 
                              ? Colors.blue 
                              : Colors.green).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status == 'completed' ? 'Completado' : 'Disponible',
                        style: TextStyle(
                          color: status == 'completed' 
                              ? Colors.blue 
                              : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Descripción/Objetivo
                    Text(
                      objective,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Duración y botón
          Row(
            children: [
              // Duración
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white54,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    duration ?? 'Sin duración',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Botón "Realizar"
              ElevatedButton(
                onPressed: () {
                  ExerciseDetailScreen.show(
                    context: context,
                    exerciseId: exerciseId,
                    name: name,
                    level: level,
                    objective: objective,
                    instructions: instructions,
                    duration: duration,
                    reflection: reflection,
                    source: source,
                    levelColor: colors[0],
                    levelIcon: Icons.workspace_premium,
                    onCompleted: onCompleted,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Realizar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
