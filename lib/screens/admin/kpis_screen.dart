import 'package:flutter/material.dart';

class KpisScreen extends StatelessWidget {
  const KpisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indicadores (KPIs)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildKpiCard(
              title: 'Citas Totales Hoy',
              value: '32',
              icon: Icons.calendar_today,
              color: Colors.blue,
            ),
            _buildKpiCard(
              title: 'Ingresos del Día',
              value: '\$856.000',
              icon: Icons.monetization_on,
              color: Colors.green,
            ),
            _buildKpiCard(
              title: 'Servicios Más Solicitados',
              value: 'Corte + Barba',
              icon: Icons.content_cut,
              color: Colors.orange,
            ),
            _buildKpiCard(
              title: 'Barbero del Día',
              value: 'Juan Pablo',
              icon: Icons.star,
              color: Colors.purple,
            ),
            _buildKpiCard(
              title: 'Clientes Nuevos Esta Semana',
              value: '14',
              icon: Icons.person_add,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
