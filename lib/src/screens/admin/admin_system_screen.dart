import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/neon_widgets.dart';
import '../../features/admin/services/admin_data_provider.dart';

class AdminSystemScreen extends StatefulWidget {
  const AdminSystemScreen({Key? key}) : super(key: key);

  @override
  State<AdminSystemScreen> createState() => _AdminSystemScreenState();
}

class _AdminSystemScreenState extends State<AdminSystemScreen> {
  final AdminDataProvider _dataProvider = AdminDataProvider.instance;
  late Map<String, dynamic> _health;

  @override
  void initState() {
    super.initState();
    _health = _dataProvider.getSystemHealth();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salud del Sistema',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Status Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sistema Operativo', style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Todo funciona correctamente', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Versión: ${_health['version']}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Metrics Grid
          Row(
            children: [
              Expanded(child: _buildMetricCard('Almacenamiento', _health['storageUsage'], Icons.storage, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Base de Datos', 'Conectada', Icons.dns, Colors.purple)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Latencia API', '45ms', Icons.speed, Colors.orange)),
            ],
          ),

          const SizedBox(height: 32),
          const NeonSectionTitle(title: 'Acciones de Mantenimiento', color: Colors.white),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: NeonButton(
                  text: 'Limpiar Caché',
                  icon: Icons.cleaning_services,
                  onTap: () {},
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: NeonButton(
                  text: 'Optimizar DB',
                  icon: Icons.storage,
                  onTap: () {},
                  color: Colors.white,
                ),
              ),
               const SizedBox(width: 16),
              Expanded(
                child: NeonButton(
                  text: 'Reiniciar Servicios',
                  icon: Icons.restart_alt,
                  onTap: () {},
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
