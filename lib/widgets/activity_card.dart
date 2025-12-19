import 'package:flutter/material.dart';
import 'custom_button.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final String category;
  final Color categoryColor;

  const ActivityCard({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.category,
    this.categoryColor = Colors.blue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Categoría en esquina superior izquierda
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Título
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Descripción que se adapta al contenido
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Botón en esquina inferior derecha
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  text: buttonText,
                  onPressed: () {
                    // Aquí se puede agregar la funcionalidad específica del botón
                  },
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
