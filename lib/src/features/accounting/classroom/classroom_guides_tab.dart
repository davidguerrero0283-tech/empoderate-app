import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/config/accounting_config.dart';
import 'package:proyecto_empoderate/src/features/accounting/classroom/accounting_class_data.dart';

class ClassroomGuidesTab extends StatelessWidget {
  const ClassroomGuidesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: AccountingClassData.guides.length,
      itemBuilder: (context, index) {
        final guide = AccountingClassData.guides[index];
        return _buildGuideCard(context, guide);
      },
    );
  }

  Widget _buildGuideCard(BuildContext context, Map<String, dynamic> guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1D).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: kNeonBlue,
          iconColor: kNeonBlue,
          title: Text(
            guide['title'],
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: Colors.white10),
                const SizedBox(height: 8),
                Text(
                  guide['whatIs'],
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                
                // How To
                Text('¿CÓMO USARLO?', style: GoogleFonts.outfit(color: kNeonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(guide['howTo'] as List).map((text) => _buildBulletPoint(text, Colors.white60)).toList(),
                
                const SizedBox(height: 16),
                
                // Alerts
                Text('SEÑALES DE ALERTA', style: GoogleFonts.outfit(color: kNeonPink, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(guide['alerts'] as List).map((text) => _buildBulletPoint(text, Colors.white60)).toList(),

                if (guide['toolId'] != null) ...[
                  const SizedBox(height: 16),
                  NeonButton(
                    text: 'IR A HERRAMIENTA',
                    onTap: () {
                      final toolId = guide['toolId'];
                      try {
                        final tool = accountingTools.firstWhere((t) => t.id == toolId);
                        Navigator.pushNamed(context, tool.route);
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Herramienta no disponible aún.')));
                      }
                    },
                    color: kNeonBlue,
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.outfit(color: color, fontSize: 13))),
        ],
      ),
    );
  }
}
