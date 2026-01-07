import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/negocio/business_content_data.dart'; // Ensure this import path is correct for RequirementItem

// --- CONSTANTS ---
const Color kGoldMain = Color(0xFFD4AF37);
const Color kDarkGlass = Color(0xFF151C2B);
final Color kTableBorder = kGoldMain.withOpacity(0.3);
final Color kTableSurface = Colors.white.withOpacity(0.03); // Very subtle surface

// ============================================================================
// 1. PREMIUM GUIDE TABLE (Left Column)
// "Encapsulates: What is it, Why needed, Steps, Requirements, Errors, Tips"
// ============================================================================
class PremiumGuideTable extends StatelessWidget {
  final RequirementItem item;

  const PremiumGuideTable({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. WHAT IS IT (Hero Card)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kDarkGlass.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kTableBorder.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(color: Colors.black45, blurRadius: 16, offset: const Offset(0, 8)),
              BoxShadow(color: kGoldMain.withOpacity(0.05), blurRadius: 30, spreadRadius: -10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: kGoldMain, size: 20),
                  const SizedBox(width: 10),
                  Text('¿QUÉ ES?', style: GoogleFonts.outfit(color: kGoldMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.whatIsIt,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),

        // 2. WHY NEEDED (List of Checkpoints)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kDarkGlass.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text('¿POR QUÉ ES NECESARIO?', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
               const SizedBox(height: 16),
               ...item.whyNeeded.map((reason) => Padding(
                 padding: const EdgeInsets.only(bottom: 12),
                 child: Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Icon(Icons.check_circle, color: const Color(0xFF4DD0E1), size: 18),
                     const SizedBox(width: 12),
                     Expanded(child: Text(reason, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14))),
                   ],
                 ),
               )).toList(),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. STEPS (Timeline Style)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGoldMain.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PASO A PASO', style: GoogleFonts.outfit(color: kGoldMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: kGoldMain.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text('${item.steps.length} Pasos', style: GoogleFonts.outfit(color: kGoldMain, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...item.steps.asMap().entries.map((entry) {
                final isLast = entry.key == item.steps.length - 1;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 24, height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kGoldMain,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: kGoldMain.withOpacity(0.4), blurRadius: 8)],
                            ),
                            child: Text('${entry.key + 1}', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          if (!isLast)
                            Expanded(child: Container(width: 2, color: kGoldMain.withOpacity(0.2))),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Text(entry.value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, height: 1.4)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 4. REQUIREMENTS & TIPS (Grid)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.commonRequirements.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Icon(Icons.inventory_2_outlined, size: 16, color: Colors.white70), SizedBox(width: 8), Text('REQUISITOS', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))]),
                      const SizedBox(height: 12),
                      ...item.commonRequirements.map((req) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('• $req', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                      )),
                    ],
                  ),
                ),
              ),
            
            if (item.commonRequirements.isNotEmpty && (item.tips.isNotEmpty || item.officialLinks.isNotEmpty))
               const SizedBox(width: 16),

            if (item.tips.isNotEmpty || item.officialLinks.isNotEmpty)
               Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFE2C15A).withOpacity(0.15), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFE2C15A).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Icon(Icons.lightbulb, size: 16, color: Color(0xFFE2C15A)), SizedBox(width: 8), Text('TIPS PRO', style: GoogleFonts.outfit(color: Color(0xFFE2C15A), fontSize: 12, fontWeight: FontWeight.bold))]),
                      const SizedBox(height: 12),
                      if (item.tips.isNotEmpty)
                        ...item.tips.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(tip, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic)),
                        )),
                      if (item.officialLinks.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Divider(color: Colors.white10),
                        const SizedBox(height: 8),
                         Wrap(
                          spacing: 8, runSpacing: 8,
                          children: item.officialLinks.entries.map((e) => GestureDetector(
                            onTap: () => _launchURL(e.value),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.link, size: 12, color: Colors.blueAccent),
                                SizedBox(width: 6),
                                Text(e.key, style: GoogleFonts.outfit(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)) // Small,
                              ]),
                            ),
                          )).toList(),
                         )
                      ]
                    ],
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch \$uri');
    }
  }
}


// ============================================================================
// 2. PREMIUM INFO TABLE (Right Column - Table 1)
// "Panel del Requisito: Entity, Priority, Status, Evidence"
// ============================================================================
class PremiumInfoTable extends StatelessWidget {
  final Map<String, String> infoData; // { 'Entidad': 'DGI', 'Prioridad': 'Alta', ... }

  const PremiumInfoTable({Key? key, required this.infoData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: kDarkGlass.withOpacity(0.95),
        border: Border.all(color: kTableBorder, width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: kTableBorder, width: 0.5)),
            ),
            child: Text(
              'PANEL DEL REQUISITO',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          // Rows
          ...infoData.entries.map((entry) {
             return Column(
               children: [
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(entry.key, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
                       Text(entry.value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                     ],
                   ),
                 ),
                 if (entry.key != infoData.keys.last)
                    Divider(height: 1, color: Colors.white.withOpacity(0.05)),
               ],
             );
          }).toList(),
        ],
      ),
    );
  }
}


// ============================================================================
// 3. PREMIUM ACTIONS TABLE (Right Column - Table 2)
// "Acciones y Evidencias: Mark Done, Request, Vault"
// ============================================================================
class PremiumActionsTable extends StatelessWidget {
  final VoidCallback? onMarkDone;
  final VoidCallback? onMarkRequest; // Placeholder for now
  final VoidCallback? onVault;
  final VoidCallback? onAddToAgenda;

  const PremiumActionsTable({
    Key? key,
    this.onMarkDone,
    this.onMarkRequest,
    this.onVault,
    this.onAddToAgenda,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kDarkGlass.withOpacity(0.95),
        border: Border.all(color: kTableBorder, width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
           // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: kTableBorder, width: 0.5)),
            ),
            child: Text(
              'ACCIONES',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),

          // Action 1: Marcar Listo
          if (onMarkDone != null)
            _buildActionRow(
              icon: Icons.check_circle_outline,
              label: 'Marcar como Listo',
              sublabel: 'Completar este requisito',
              btnLabel: 'LISTO',
              color: Colors.greenAccent,
              onTap: onMarkDone!,
            ),
          
          _buildDivider(),

          // Action 2: Marcar Solicitud
          if (onMarkRequest != null)
             _buildActionRow(
              icon: Icons.assignment_turned_in_outlined,
              label: 'Marcar Solicitud',
              sublabel: 'Marcar como en proceso',
              btnLabel: 'SOLICITUD',
              color: kGoldMain,
              onTap: onMarkRequest!,
            ),

          _buildDivider(),

          // Action 3: Boveda
          if (onVault != null)
             _buildActionRow(
              icon: Icons.cloud_upload_outlined,
              label: 'Guardar en Bóveda',
              sublabel: 'Subir evidencia o pendiente',
              btnLabel: 'SUBIR',
              color: Colors.blueAccent,
              onTap: onVault!,
            ),
            
          _buildDivider(),

          // Action 4: Agenda
          if (onAddToAgenda != null)
             _buildActionRow(
              icon: Icons.calendar_today_outlined,
              label: 'Agregar a Agenda',
              sublabel: 'Crear recordatorio o tarea',
              btnLabel: 'AGENDAR',
              color: const Color(0xFFFFD740),
              onTap: onAddToAgenda!,
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withOpacity(0.05));
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required String sublabel,
    required String btnLabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon Left
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(sublabel, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Button
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withOpacity(0.1),
                foregroundColor: color,
                elevation: 0,
                side: BorderSide(color: color.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              child: Text(btnLabel),
            ),
          ),
        ],
      ),
    );
  }
}
