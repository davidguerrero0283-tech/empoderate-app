import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/neon_widgets.dart';
import '../../components/how_to_use_card.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This widget is embedded inside AdminLayout, so no need for Scaffold
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analítica Detallada',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exportando CSV...')),
                  );
                },
                icon: const Icon(Icons.download, color: Color(0xFF00E5FF)),
                label: const Text('Exportar', style: TextStyle(color: Color(0xFF00E5FF))),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // How to Use Card
          const HowToUseCard(
            title: '¿Cómo usar Analytics?',
            icon: Icons.bar_chart,
            accentColor: Color(0xFF00E5FF),
            steps: [
              'Revisa los KPIs principales en las tarjetas superiores.',
              'Analiza el desglose por módulo para ver qué secciones son más populares.',
              'Usa el botón "Exportar" para descargar los datos en formato CSV.',
              'Los datos se actualizan automáticamente cada hora.',
            ],
          ),

          const SizedBox(height: 16),

          // KPI Cards - Using Wrap for responsiveness
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildKpiCard('Visitas Totales', '3,450', '+12%', Colors.blue),
              _buildKpiCard('Tiempo Promedio', '4m 12s', '+5%', Colors.green),
              _buildKpiCard('Tasa Rebote', '28%', '-2%', Colors.orange),
              _buildKpiCard('Conversión', '4.5%', '+0.5%', Colors.purple),
            ],
          ),
          
          const SizedBox(height: 32),
          
          const NeonSectionTitle(title: 'Desglose por Módulo', color: Colors.white),
          const SizedBox(height: 16),
          
          // Module Rows (Simpler than DataTable)
          _buildModuleRow('Contabilidad', '1,200', '3m 45s', '22%', Colors.blue),
          _buildModuleRow('RRHH', '890', '5m 10s', '18%', Colors.purple),
          _buildModuleRow('Marketing', '650', '4m 30s', '32%', Colors.pink),
          _buildModuleRow('Legal', '710', '6m 05s', '15%', Colors.orange),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String trend, Color color) {
    final isPositive = trend.startsWith('+');
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border(bottom: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              trend, 
              style: GoogleFonts.outfit(
                color: isPositive ? Colors.greenAccent : Colors.redAccent, 
                fontSize: 11, 
                fontWeight: FontWeight.bold
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleRow(String module, String visits, String avgTime, String bounce, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 10, height: 10, 
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(module, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Visitas', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
                Text(visits, style: GoogleFonts.outfit(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tiempo', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
                Text(avgTime, style: GoogleFonts.outfit(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rebote', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
                Text(bounce, style: GoogleFonts.outfit(color: Colors.white70)),
              ],
            ),
          ),
          const Icon(Icons.trending_up, color: Colors.greenAccent, size: 18),
        ],
      ),
    );
  }
}
