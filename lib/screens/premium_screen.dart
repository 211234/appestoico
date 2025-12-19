import 'package:flutter/material.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icono Premium
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),

                // Título
                const Text(
                  'Estoica Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Desbloquea todo el potencial de tu práctica estoica',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Beneficios
                _buildFeatureItem(
                  icon: Icons.auto_stories,
                  title: 'Contenido Ilimitado',
                  description:
                      'Acceso completo a todas las lecciones, videos y artículos',
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  icon: Icons.emoji_events,
                  title: 'Desafíos Exclusivos',
                  description: 'Retos especiales con recompensas premium',
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  icon: Icons.spa,
                  title: 'Meditaciones Guiadas',
                  description:
                      'Biblioteca completa de prácticas de mindfulness',
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  icon: Icons.support_agent,
                  title: 'Soporte Prioritario',
                  description: 'Asistencia personalizada cuando la necesites',
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  icon: Icons.cloud_off,
                  title: 'Sin Anuncios',
                  description: 'Experiencia fluida sin interrupciones',
                ),

                const SizedBox(height: 40),

                // Planes
                _buildPlanCard(
                  isPopular: false,
                  title: 'Mensual',
                  price: '\$4.99',
                  period: '/mes',
                  features: [
                    'Acceso completo',
                    'Sin anuncios',
                    'Cancela cuando quieras',
                  ],
                  color: Colors.blue,
                ),

                const SizedBox(height: 16),

                _buildPlanCard(
                  isPopular: true,
                  title: 'Anual',
                  price: '\$39.99',
                  period: '/año',
                  savings: 'Ahorra 33%',
                  features: [
                    'Todo lo del plan mensual',
                    'Mejor precio',
                    '3 meses gratis',
                  ],
                  color: Colors.orange,
                ),

                const SizedBox(height: 16),

                _buildPlanCard(
                  isPopular: false,
                  title: 'De por vida',
                  price: '\$99.99',
                  period: 'pago único',
                  features: [
                    'Acceso permanente',
                    'Todas las actualizaciones',
                    'Sin pagos recurrentes',
                  ],
                  color: Colors.purple,
                ),

                const SizedBox(height: 30),

                // Nota legal
                const Text(
                  'El pago se cargará a tu cuenta. La suscripción se renueva automáticamente a menos que se cancele 24 horas antes.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.orange, size: 24),
        ),
        const SizedBox(width: 16),
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
                description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required bool isPopular,
    required String title,
    required String price,
    required String period,
    String? savings,
    required List<String> features,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? color : Colors.grey[800]!,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con badge si es popular
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Precio
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: color,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  period,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),

          if (savings != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                savings,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Features
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: color, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    feature,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Botón
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implementar lógica de suscripción
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Suscripción $title próximamente'),
                    backgroundColor: color,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Suscribirse',
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
    );
  }
}
