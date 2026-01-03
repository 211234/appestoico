import 'package:flutter/material.dart';

class SubscriptionSuccessScreen extends StatefulWidget {
  const SubscriptionSuccessScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionSuccessScreen> createState() =>
      _SubscriptionSuccessScreenState();
}

class _SubscriptionSuccessScreenState extends State<SubscriptionSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Redirigir a home después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de éxito
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 30),
            // Título
            const Text(
              '¡Suscripción Exitosa!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            // Descripción
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Tu suscripción ha sido activada correctamente. Ahora tienes acceso a todas las funcionalidades premium.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),
            // Botón para ir a inicio
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              },
              child: const Text(
                'Ir a Inicio',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
