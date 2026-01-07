import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/neon_widgets.dart';
import '../../components/how_to_use_card.dart';

class AdminAuditScreen extends StatelessWidget {
  const AdminAuditScreen({Key? key}) : super(key: key);

  // Mock audit logs
  static final List<Map<String, dynamic>> _logs = [
    {'action': 'Usuario Creado', 'details': 'Se creó el usuario juan@test.com con rol User', 'user': 'admin@empoderate.com', 'time': 'Hoy, 10:30'},
    {'action': 'Contenido Editado', 'details': 'Artículo "Finanzas 101" actualizado', 'user': 'editor@empoderate.com', 'time': 'Hoy, 09:15'},
    {'action': 'Rol Cambiado', 'details': 'maria@test.com promovido a Pro', 'user': 'admin@empoderate.com', 'time': 'Ayer, 18:45'},
    {'action': 'Login Fallido', 'details': 'Intento de login desde IP 192.168.1.50', 'user': 'desconocido', 'time': 'Ayer, 14:22'},
    {'action': 'Sistema', 'details': 'Backup automático completado', 'user': 'sistema', 'time': 'Ayer, 03:00'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registro de Auditoría',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exportando logs...')),
                  );
                },
                icon: const Icon(Icons.download, color: Color(0xFF00E5FF)),
                label: const Text('Exportar', style: TextStyle(color: Color(0xFF00E5FF))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Monitorea cambios críticos, accesos y actividades administrativas.',
            style: GoogleFonts.outfit(color: Colors.white54),
          ),
          const SizedBox(height: 20),

          // How to Use Card
          const HowToUseCard(
            title: '¿Cómo usar Auditoría?',
            icon: Icons.history_edu,
            accentColor: Colors.orangeAccent,
            steps: [
              'Revisa el historial de acciones importantes del sistema.',
              'Cada evento muestra: acción, detalles, usuario responsable y hora.',
              'Usa "Exportar" para descargar el log completo.',
              'Filtra eventos de seguridad como "Login Fallido" para detectar amenazas.',
            ],
          ),

          const SizedBox(height: 20),

          // Audit Log List
          ..._logs.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value;
            return _buildLogItem(log, index == _logs.length - 1);
          }).toList(),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log, bool isLast) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Dot
          Column(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80, // Fixed height for timeline connector
                  color: Colors.white10,
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        log['action'], 
                        style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold)
                      ),
                      Text(log['time'], style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    log['details'],
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        'Usuario: ${log['user']}',
                        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
