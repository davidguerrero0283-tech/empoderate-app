import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../components/premium_scaffold.dart';
import '../../../../ui/theme/empoderate_theme.dart';

class CalendarioObligacionesScreen extends StatelessWidget {
  const CalendarioObligacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Calendario RRHH',
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fechas límite críticas para evitar multas',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            _buildMonthSection('Mensual (Recurrente)', [
              _buildEventTile(
                day: '20',
                title: 'Planilla SIPE',
                desc: 'Fecha límite para presentación de planilla en SIPE.',
                color: Colors.blueAccent,
              ),
              _buildEventTile(
                day: '30',
                title: 'Pago CSS',
                desc: 'Fecha límite de pago sin recargos (último día del mes).',
                color: Colors.lightBlueAccent,
              ),
            ]),
            const SizedBox(height: 24),

            _buildMonthSection('Abril', [
              _buildEventTile(
                day: '15',
                title: 'Décimo - Primera Partida',
                desc: 'Pago obligatorio del XIII Mes (Meses Dic-Abr).',
                color: Colors.amber,
              ),
            ]),
            const SizedBox(height: 24),

            _buildMonthSection('Agosto', [
              _buildEventTile(
                day: '15',
                title: 'Décimo - Segunda Partida',
                desc: 'Pago obligatorio del XIII Mes (Meses Abr-Ago).',
                color: Colors.amber,
              ),
            ]),
            const SizedBox(height: 24),

             _buildMonthSection('Diciembre', [
              _buildEventTile(
                day: '15',
                title: 'Décimo - Tercera Partida',
                desc: 'Pago obligatorio del XIII Mes (Meses Ago-Dic).',
                color: Colors.amber,
              ),
            ]),

            const SizedBox(height: 32),
            _buildSectionTitle('Herramientas'),
            const SizedBox(height: 12),
            _buildTools(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: EmpoderateTheme.gold,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMonthSection(String month, List<Widget> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            month,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        ...events,
      ],
    );
  }

  Widget _buildEventTile({required String day, required String title, required String desc, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:  Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(day, style: GoogleFonts.outfit(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('DÍA', style: TextStyle(color: Colors.white38, fontSize: 8)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTools(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'Añadir Recordatorios',
            Icons.notification_add,
            Colors.purpleAccent,
            () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recordatorios añadidos a tu calendario')));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            'Calc. Décimo',
            Icons.calculate,
            Colors.amber,
            () => context.push('/decimo_calculator'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
