import 'package:flutter/material.dart';

class HorarioSelector extends StatelessWidget {
  final TimeOfDay? horaSeleccionada;
  final ValueChanged<TimeOfDay> onHoraSeleccionada;
  final String label;

  const HorarioSelector({
    Key? key,
    required this.horaSeleccionada,
    required this.onHoraSeleccionada,
    this.label = 'Selecciona un horario',
  }) : super(key: key);

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horaSeleccionada ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null && picked != horaSeleccionada) {
      onHoraSeleccionada(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _seleccionarHora(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Text(
              horaSeleccionada != null
                  ? horaSeleccionada!.format(context)
                  : '--:--',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.access_time, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
