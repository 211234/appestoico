import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/sweet_alert.dart';
import '../models/reflection.dart';
import 'package:intl/intl.dart' as intl;

class NewReflectionScreen extends StatefulWidget {
  final Reflection? existingReflection;

  const NewReflectionScreen({Key? key, this.existingReflection})
    : super(key: key);

  @override
  State<NewReflectionScreen> createState() => _NewReflectionScreenState();
}

class _NewReflectionScreenState extends State<NewReflectionScreen> {
  final TextEditingController _reflectionController = TextEditingController();
  bool _isSaving = false;
  String? _reflectionId;

  @override
  void initState() {
    super.initState();
    if (widget.existingReflection != null) {
      final reflection = widget.existingReflection!;
      _reflectionId = reflection.id;
      _reflectionController.text = reflection.morningText ?? '';
    }
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _saveReflection() async {
    if (_reflectionController.text.trim().isEmpty) {
      SweetAlert.showError(
        context: context,
        title: 'Campo vacío',
        message: 'Por favor escribe tu reflexión',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    Map<String, dynamic> result;

    if (_reflectionId != null) {
      result = await ApiService.updateReflection(
        id: _reflectionId!,
        morningText: _reflectionController.text.trim(),
      );
    } else {
      final now = DateTime.now();
      final dateStr = intl.DateFormat('yyyy-MM-dd').format(now);
      result = await ApiService.saveMorningReflection(
        date: dateStr,
        morningText: _reflectionController.text.trim(),
      );
    }

    setState(() {
      _isSaving = false;
    });

    if (result['success']) {
      SweetAlert.showSuccess(
        context: context,
        title: _reflectionId != null
            ? 'Reflexión actualizada'
            : 'Reflexión guardada',
        message:
            '✨ Tu reflexión ha sido ${_reflectionId != null ? "actualizada" : "guardada"} exitosamente',
        backgroundColor: const Color(0xFF102110),
      ).then((_) {
        Navigator.of(context).pop(true);
      });
    } else {
      String errorMessage =
          result['message'] ?? 'No se pudo guardar la reflexión';

      // Si el error es de restricción de horario, mostrar mensaje personalizado
      if (errorMessage.contains('horario') ||
          errorMessage.contains('00:00-11:59')) {
        errorMessage =
            'Hubo un error al guardar tu reflexión. Por favor intenta nuevamente.';
      }

      SweetAlert.showError(
        context: context,
        title: 'Error al guardar',
        message: errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = intl.DateFormat(
      'EEEE, d \'de\' MMMM yyyy',
      'es',
    ).format(now);
    final timeStr = intl.DateFormat('HH:mm', 'es').format(now);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _reflectionId != null ? 'Editar Reflexión' : 'Nueva Reflexión',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha y hora automática (solo lectura)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hora: $timeStr',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_note,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Reflexión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: TextField(
                controller: _reflectionController,
                maxLines: 8,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText:
                      '¿Cómo quieres abordar el día? ¿Qué principios Estoicos aplicarás?',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveReflection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Guardar Reflexión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
