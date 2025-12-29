import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../widgets/horario_selector.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;

  const EditProfileScreen({Key? key, required this.currentData})
    : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _selectedAgeRange;
  String? _selectedGender;
  String? _selectedCountry;
  String? _selectedReligiousBelief;
  String? _selectedSpiritualLevel;
  String? _selectedSpiritualFrequency;
  String? _selectedStoicLevel;
  List<String> _selectedDailyChallenges = [];
  List<String> _selectedStoicPaths = [];
  Map<String, TimeOfDay?> _horariosPorRecordatorio = {};
  bool _isLoading = false;

  final List<Map<String, String>> _ageRanges = [
    {'value': '18-25', 'label': '18-25 años'},
    {'value': '26-35', 'label': '26-35 años'},
    {'value': '36-45', 'label': '36-45 años'},
    {'value': '46-55', 'label': '46-55 años'},
    {'value': '56+', 'label': '56+ años'},
  ];

  final List<Map<String, String>> _genders = [
    {'value': 'masculino', 'label': 'Masculino'},
    {'value': 'femenino', 'label': 'Femenino'},
    {'value': 'otro', 'label': 'Otro'},
  ];

  final List<Map<String, String>> _countries = [
    {'value': 'MX', 'label': 'México'},
    {'value': 'ES', 'label': 'España'},
    {'value': 'AR', 'label': 'Argentina'},
    {'value': 'CO', 'label': 'Colombia'},
    {'value': 'PE', 'label': 'Perú'},
    {'value': 'CL', 'label': 'Chile'},
    {'value': 'US', 'label': 'Estados Unidos'},
    {'value': 'OTRO', 'label': 'Otro'},
  ];

  final List<Map<String, String>> _religiousBeliefs = [
    {'value': 'catolico', 'label': 'Católico'},
    {'value': 'cristiano', 'label': 'Cristiano'},
    {'value': 'evangelico', 'label': 'Evangélico'},
    {'value': 'ateo', 'label': 'Ateo'},
    {'value': 'agnostico', 'label': 'Agnóstico'},
    {'value': 'budista', 'label': 'Budista'},
    {'value': 'hindu', 'label': 'Hindú'},
    {'value': 'musulman', 'label': 'Musulmán'},
    {'value': 'otro', 'label': 'Otro'},
    {'value': 'ninguna', 'label': 'Ninguna'},
  ];

  final List<Map<String, String>> _spiritualLevels = [
    {'value': 'bajo', 'label': 'Bajo - Raramente reflexiono'},
    {'value': 'medio', 'label': 'Medio - A veces reflexiono'},
    {'value': 'alto', 'label': 'Alto - Frecuentemente reflexiono'},
  ];

  final List<Map<String, String>> _spiritualFrequencies = [
    {'value': 'diario', 'label': 'Diariamente'},
    {'value': 'semanal', 'label': 'Varias veces a la semana'},
    {'value': 'mensual', 'label': 'Ocasionalmente'},
    {'value': 'nunca', 'label': 'Nunca'},
  ];

  final List<Map<String, String>> _knowledgeLevels = [
    {'value': 'Principiante', 'label': 'Principiante'},
    {'value': 'Básico Intermedio', 'label': 'Básico Intermedio'},
    {'value': 'Intermedio', 'label': 'Intermedio'},
    {'value': 'Intermedio Avanzado', 'label': 'Intermedio Avanzado'},
    {'value': 'Avanzado', 'label': 'Avanzado'},
  ];

  final List<Map<String, dynamic>> _dailyChallenges = [
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

  final List<Map<String, dynamic>> _stoicGoals = [
    {
      'title': 'Paz Interior',
      'description': 'Encontrar calma en el caos diario',
      'icon': Icons.spa,
    },
    {
      'title': 'Autocontrol',
      'description': 'Dominar mis emociones y reacciones',
      'icon': Icons.psychology,
    },
    {
      'title': 'Sabiduría',
      'description': 'Desarrollar perspectiva y entendimiento',
      'icon': Icons.lightbulb,
    },
    {
      'title': 'Resiliencia',
      'description': 'Ser fuerte ante las adversidades',
      'icon': Icons.shield,
    },
    {
      'title': 'Propósito',
      'description': 'Encontrar significado en mi vida',
      'icon': Icons.track_changes,
    },
    {
      'title': 'Equilibrio',
      'description': 'Balancear todas las áreas de mi vida',
      'icon': Icons.balance,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedAgeRange = widget.currentData['age_range'];
    _selectedGender = widget.currentData['gender'];
    _selectedCountry = widget.currentData['country'];
    _selectedReligiousBelief = widget.currentData['religious_belief'];
    _selectedSpiritualLevel = widget.currentData['spiritual_practice_level'];
    _selectedSpiritualFrequency =
        widget.currentData['spiritual_practice_frequency'];
    _selectedStoicLevel = widget.currentData['stoic_level'];

    // Inicializar listas desde los datos actuales
    if (widget.currentData['daily_challenges'] != null) {
      _selectedDailyChallenges = List<String>.from(
        widget.currentData['daily_challenges'],
      );
    }
    if (widget.currentData['stoic_paths'] != null) {
      _selectedStoicPaths = List<String>.from(
        widget.currentData['stoic_paths'],
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _reprogramNotifications() async {
    // Cancelar todas las notificaciones actuales
    await NotificationService.cancelAllNotifications();

    // Reprogramar notificaciones para cada recordatorio seleccionado
    for (final challengeKey in _selectedDailyChallenges) {
      // Encontrar el desafío
      final challenge = _dailyChallenges.firstWhere(
        (c) => c['key'] == challengeKey,
        orElse: () => {'title': challengeKey, 'description': ''},
      );

      final notificationId = NotificationService.getReminderNotificationId(
        challengeKey,
      );

      // Obtener el horario configurado o usar 9:00 AM por defecto
      final horario =
          _horariosPorRecordatorio[challengeKey] ??
          const TimeOfDay(hour: 9, minute: 0);

      // Programar notificación con el horario configurado
      await NotificationService.scheduleDailyNotification(
        id: notificationId,
        title: challenge['title'],
        body: challenge['description'],
        time: horario,
        scheduledTime: horario,
      );
    }
  }

  Future<void> _saveChanges() async {
    // Validar solo campos obligatorios básicos
    if (_selectedAgeRange == null ||
        _selectedGender == null ||
        _selectedCountry == null ||
        _selectedReligiousBelief == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor completa los campos de información personal',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Enviar datos del quiz al backend (nombre/apellidos no se actualizan, dailyChallenges son solo notificaciones)
    final result = await ApiService.updateProfile(
      ageRange: _selectedAgeRange!,
      gender: _selectedGender!,
      country: _selectedCountry!,
      religiousBelief: _selectedReligiousBelief!,
      spiritualPracticeLevel: _selectedSpiritualLevel ?? 'medio',
      spiritualPracticeFrequency: _selectedSpiritualFrequency ?? 'semanal',
      stoicPaths: _selectedStoicPaths,
      stoicLevel: _selectedStoicLevel,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      if (mounted) {
        // Reprogramar notificaciones con los nuevos recordatorios
        await _reprogramNotifications();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Retornar true para recargar perfil
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al actualizar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información Personal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Actualiza toda la información de tu perfil estoico',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Sección 1: Información Personal
                  const Text(
                    '📋 Información Personal',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rango de edad
                  _buildDropdownField(
                    label: 'Rango de Edad',
                    value: _selectedAgeRange,
                    items: _ageRanges,
                    onChanged: (value) {
                      setState(() {
                        _selectedAgeRange = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Género
                  _buildDropdownField(
                    label: 'Género',
                    value: _selectedGender,
                    items: _genders,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // País
                  _buildDropdownField(
                    label: 'País',
                    value: _selectedCountry,
                    items: _countries,
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Creencia religiosa
                  _buildDropdownField(
                    label: 'Creencia Religiosa',
                    value: _selectedReligiousBelief,
                    items: _religiousBeliefs,
                    onChanged: (value) {
                      setState(() {
                        _selectedReligiousBelief = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Sección 2: Práctica Espiritual
                  const Text(
                    '🧘 Práctica Espiritual',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nivel de práctica espiritual
                  _buildDropdownField(
                    label: 'Nivel de Práctica Espiritual',
                    value: _selectedSpiritualLevel,
                    items: _spiritualLevels,
                    onChanged: (value) {
                      setState(() {
                        _selectedSpiritualLevel = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Frecuencia de práctica espiritual
                  _buildDropdownField(
                    label: 'Frecuencia de Práctica',
                    value: _selectedSpiritualFrequency,
                    items: _spiritualFrequencies,
                    onChanged: (value) {
                      setState(() {
                        _selectedSpiritualFrequency = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Sección 3: Nivel de Conocimiento
                  const Text(
                    '📚 Nivel de Conocimiento del Estoicismo',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nivel de conocimiento
                  _buildDropdownField(
                    label: 'Tu Nivel',
                    value: _selectedStoicLevel,
                    items: _knowledgeLevels,
                    onChanged: (value) {
                      setState(() {
                        _selectedStoicLevel = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Sección 4: Recordatorios Diarios
                  const Text(
                    '🎯 Recordatorios Diarios',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona los recordatorios que desees (opcional)',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Lista de recordatorios
                  ..._dailyChallenges.map((challenge) {
                    final isSelected = _selectedDailyChallenges.contains(
                      challenge['key'],
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedDailyChallenges.remove(
                                    challenge['key'],
                                  );
                                  _horariosPorRecordatorio.remove(
                                    challenge['key'],
                                  );
                                } else {
                                  _selectedDailyChallenges.add(
                                    challenge['key'],
                                  );
                                  _horariosPorRecordatorio[challenge['key']] =
                                      null;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.grey[900],
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.grey[700]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (challenge['color'] as Color)
                                          .withOpacity(0.2),
                                    ),
                                    child: Icon(
                                      challenge['icon'],
                                      color: challenge['color'],
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          challenge['description'],
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.orange
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.orange
                                            : Colors.grey[600]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Selector de horario cuando está seleccionado
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                left: 8,
                                right: 8,
                              ),
                              child: HorarioSelector(
                                horaSeleccionada:
                                    _horariosPorRecordatorio[challenge['key']],
                                onHoraSeleccionada: (hora) {
                                  setState(() {
                                    _horariosPorRecordatorio[challenge['key']] =
                                        hora;
                                  });
                                },
                                label: 'Horario para este recordatorio',
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 32),

                  // Sección 5: Caminos Estoicos
                  const Text(
                    '🌱 Caminos Estoicos',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona al menos 2 objetivos',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Lista de caminos estoicos
                  ..._stoicGoals.map((goal) {
                    final isSelected = _selectedStoicPaths.contains(
                      goal['title'],
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedStoicPaths.remove(goal['title']);
                            } else {
                              _selectedStoicPaths.add(goal['title']);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.orange.withOpacity(0.2)
                                : Colors.grey[900],
                            border: Border.all(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.grey[700]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.orange.withOpacity(0.2),
                                ),
                                child: Icon(
                                  goal['icon'],
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal['title'],
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.orange
                                            : Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      goal['description'],
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.orange
                                        : Colors.grey[600]!,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 32),

                  // Nota informativa
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Las notificaciones se reprogramarán automáticamente con tus nuevas preferencias',
                            style: TextStyle(color: Colors.blue, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Botón de guardar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          color: Colors.white,
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
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[600]),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(item['label']!),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
