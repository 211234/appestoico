import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/reflection.dart';
import 'new_reflection_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<Reflection> _reflections = [];
  bool _isLoading = true;
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('es', null);
    setState(() {
      _isLocaleInitialized = true;
    });
    _loadReflections();
  }

  Future<void> _loadReflections() async {
    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.getAllReflections();

    if (result['success']) {
      setState(() {
        _reflections = result['data'] as List<Reflection>;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al cargar reflexiones'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Sin fecha';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final checkDate = DateTime(date.year, date.month, date.day);

      if (checkDate == today) {
        return 'Hoy';
      } else if (checkDate == today.subtract(const Duration(days: 1))) {
        return 'Ayer';
      } else {
        return DateFormat('d \'de\' MMMM', 'es').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  void _navigateToNewReflection() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NewReflectionScreen()),
    );

    if (result == true) {
      _loadReflections();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Esperar a que el locale se inicialice
    if (!_isLocaleInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    final todayDate = DateFormat(
      'EEEE, d \'de\' MMMM',
      'es',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Diario Estoico',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              todayDate,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _reflections.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 80, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay reflexiones aún',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Comienza tu primera reflexión',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadReflections,
              color: Colors.orange,
              backgroundColor: Colors.black,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Reflexiones Recientes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._reflections.map((reflection) {
                    return _buildReflectionCard(reflection);
                  }).toList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewReflection,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildReflectionCard(Reflection reflection) {
    // Obtener la hora de creación o actualización
    String timeStr = '';

    // Priorizar el campo 'time' del backend
    if (reflection.time != null && reflection.time!.isNotEmpty) {
      timeStr = reflection.time!;
    } else {
      // Fallback: intentar extraer hora de created_at o updated_at
      try {
        final dateSource =
            reflection.updatedAt ?? reflection.createdAt ?? reflection.date;
        if (dateSource != null) {
          final dateTime = DateTime.parse(dateSource);
          timeStr = DateFormat('HH:mm:ss', 'es').format(dateTime);
        }
      } catch (e) {
        timeStr = '';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fecha y hora
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(reflection.date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (timeStr.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white54,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        // Mostrar badge de "Editado" si fue actualizado
                        if (reflection.updatedAt != null &&
                            reflection.createdAt != null &&
                            reflection.updatedAt != reflection.createdAt) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Editado',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contenido de la reflexión
          if (reflection.hasReflection || reflection.hasMorningReflection) ...[
            Text(
              reflection.text ?? reflection.morningText ?? '',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],

          // Botones de acción
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botón Editar
              OutlinedButton.icon(
                onPressed: () => _editReflection(reflection),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Editar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón Eliminar
              OutlinedButton.icon(
                onPressed: () => _deleteReflection(reflection),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Eliminar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editReflection(Reflection reflection) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            NewReflectionScreen(existingReflection: reflection),
      ),
    );

    if (result == true) {
      _loadReflections();
    }
  }

  void _deleteReflection(Reflection reflection) async {
    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          '¿Eliminar reflexión?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar la reflexión del ${_formatDate(reflection.date)}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Verificar que el ID no sea nulo
      if (reflection.id == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: ID de reflexión no válido'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );

      final result = await ApiService.deleteReflection(reflection.id!);

      // Cerrar indicador de carga
      if (mounted) Navigator.of(context).pop();

      if (result['success']) {
        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reflexión eliminada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadReflections();
        }
      } else {
        // Mostrar error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error al eliminar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
