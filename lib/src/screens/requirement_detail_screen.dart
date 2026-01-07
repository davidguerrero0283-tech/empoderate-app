import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/premium_scaffold.dart';
import 'package:go_router/go_router.dart';
import '../components/business_hero_header.dart'; // [NEW] Premium Header
import '../data/negocio/business_content_data.dart';
import '../components/empo_help_card.dart';
import '../components/premium_detail_tables.dart';
// import '../features/agenda/screens/agenda_creation_modal.dart'; // OLD - REMOVED

class RequirementDetailScreen extends StatelessWidget {
  final RequirementItem item;
  final VoidCallback? onMarkComplete;
  final String? categoryName;
  final String? rubroName;

  const RequirementDetailScreen({
    Key? key,
    required this.item,
    this.onMarkComplete,
    this.categoryName,
    this.rubroName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Premium theme colors
    const Color goldText = Color(0xFFD4AF37);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F1520),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 900;
          final double contentMaxWidth = 1240.0;
          
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              children: [
                // 1. NEW HERO HEADER
                BusinessHeroHeader(
                  title: item.title,
                  categoryName: categoryName ?? 'REQUISITO',
                  icon: item.icon,
                  onBackPressed: () => Navigator.pop(context),
                ),

                // 2. CONTENT BODY
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          if (isDesktop) 
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // LEFT COLUMN: GUIDE
                                Expanded(
                                  flex: 60,
                                  child: _buildGlassContainer(
                                    child: PremiumGuideTable(item: item),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // RIGHT COLUMN: META & ACTIONS
                                Expanded(
                                  flex: 40,
                                  child: Column(
                                    children: [
                                      _buildGlassContainer(
                                        child: PremiumInfoTable(
                                          infoData: {
                                            'Entidad': 'Autoridad Competente', 
                                            'Prioridad': item.title.toLowerCase().contains('opcional') ? 'Opcional' : 'Alta',
                                            'Estado': 'Pendiente', 
                                            'Sección': categoryName ?? 'General',
                                            'Bóveda': item.vaultEnabled ? 'Disponible' : 'No aplica',
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      if (item.vaultEnabled) ...[
                                         _buildVaultCard(context),
                                         const SizedBox(height: 24),
                                      ],
                                      _buildGlassContainer(
                                        child: PremiumActionsTable(
                                          onMarkDone: onMarkComplete != null ? () {
                                            onMarkComplete!();
                                            Navigator.pop(context);
                                          } : null,
                                          onMarkRequest: () => _showSnackBar(context, 'Solicitud marcada ✅'),
                                          onAddToAgenda: () {
                                            context.push('/agenda_tramites');
                                            _showSnackBar(context, 'Agenda abierta');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else 
                            // MOBILE STACK
                            Column(
                              children: [
                                _buildGlassContainer(
                                  child: PremiumGuideTable(item: item),
                                ),
                                const SizedBox(height: 24),
                                
                                _buildGlassContainer(
                                  child: PremiumInfoTable(
                                      infoData: {
                                        'Entidad': 'Autoridad Competente',
                                        'Prioridad': item.title.toLowerCase().contains('opcional') ? 'Opcional' : 'Alta',
                                        'Estado': 'Pendiente',
                                        'Sección': categoryName ?? 'General',
                                        'Bóveda': item.vaultEnabled ? 'Disponible' : 'No aplica',
                                      },
                                  ),
                                ),
                                const SizedBox(height: 24),

                                 if (item.vaultEnabled) ...[
                                       _buildVaultCard(context),
                                       const SizedBox(height: 24),
                                 ],

                                _buildGlassContainer(
                                  child: PremiumActionsTable(
                                     onMarkDone: onMarkComplete != null ? () {
                                          onMarkComplete!();
                                          Navigator.pop(context);
                                        } : null,
                                        onMarkRequest: () => _showSnackBar(context, 'Solicitud marcada ✅'),
                                        onAddToAgenda: () {
                                          context.push('/agenda_tramites');
                                          _showSnackBar(context, 'Agenda abierta');
                                        },
                                  ),
                                ),
                                const SizedBox(height: 24),

                                EmpoMiniCard(onAsk: (q) {}),
                              ],
                            ),
                          
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  // Helper for Glass Effect
  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B).withOpacity(0.6), // Semi-transparent dark
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: const Color(0xFF151C2B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFD4AF37))),
      )
    );
  }

  // --- VAULT CARD WIDGET ---
  Widget _buildVaultCard(BuildContext context) {
    const Color goldText = Color(0xFFD4AF37);
    const Color darkGlass = Color(0xFF151C2B);  
    final Color borderColor = goldText.withOpacity(0.3);

    return Container(
      width: double.infinity,
      decoration: EmpoderateTheme.safeBoxDecoration(
        color: darkGlass.withOpacity(0.95),
        border: Border.all(color: EmpoderateTheme.goldStrong.withOpacity(0.6), width: 1.5), // Stronger Gold Border
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: EmpoderateTheme.goldStrong.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4)),
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
              border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BÓVEDA DIGITAL',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
                  ),
                  child: Text('Disponible', style: GoogleFonts.outfit(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                 // Status / Icon
                 Row(
                   children: [
                     Icon(Icons.folder_special_outlined, color: Colors.blueAccent, size: 28),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Text(
                         'Gestiona tus documentos seguros aquí.',
                         style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
                       ),
                     )
                   ],
                 ),
                 const SizedBox(height: 16),
                 
                 // Main Button: Guardar
                 SizedBox(
                   width: double.infinity,
                   child: ElevatedButton.icon(
                     onPressed: () => _showVaultOptions(context),
                     icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                     label: const Text('GUARDAR EN BÓVEDA'),
                     style: EmpoderateTheme.primaryButtonStyle, // Gold CTA
                   ),
                 ),
                 
                 const SizedBox(height: 10),
                 
                 // Secondary Actions Row
                 Row(
                   children: [
                     // Ver en Boveda
                     Expanded(
                       child: OutlinedButton(
                         onPressed: () {
                           // Navigate or show 'Empty'
                           _simulateSaveToVault(context, 'No hay archivos para ver');
                         },
                         child: const Text('Ver Archivos'),
                         style: OutlinedButton.styleFrom(
                           foregroundColor: Colors.white70,
                           side: BorderSide(color: Colors.white12),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                           padding: const EdgeInsets.symmetric(vertical: 10),
                           textStyle: GoogleFonts.outfit(fontSize: 12),
                         ),
                       ),
                     ),
                     const SizedBox(width: 10),
                     // Crear pendiente
                     Expanded(
                       child: OutlinedButton(
                         onPressed: () {
                           _simulateSaveToVault(context, 'Pendiente creado');
                         },
                         child: const Text('Crear Pendiente'),
                         style: OutlinedButton.styleFrom(
                           foregroundColor: Colors.white70,
                           side: BorderSide(color: Colors.white12),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                           padding: const EdgeInsets.symmetric(vertical: 10),
                           textStyle: GoogleFonts.outfit(fontSize: 12),
                         ),
                       ),
                     ),
                   ],
                 )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showVaultOptions(BuildContext context) {
    const Color goldText = Color(0xFFD4AF37);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, 
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1520),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: goldText.withOpacity(0.3))),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Icon(Icons.folder_special, color: goldText),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Guardar en Bóveda Digital',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(ctx),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Documento: ${item.title}',
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            _buildVaultOption(
              icon: Icons.upload_file,
              label: 'Subir archivo (PDF/Img)',
              sublabel: 'Selecciona de tu dispositivo',
              onTap: () {
                Navigator.pop(ctx);
                _simulateSaveToVault(context, 'Archivo subido');
              },
            ),
            _buildVaultOption(
              icon: Icons.camera_alt_outlined,
              label: 'Tomar foto',
              sublabel: 'Captura el documento ahora',
              onTap: () {
                Navigator.pop(ctx);
                _simulateSaveToVault(context, 'Foto capturada');
              },
            ),
            _buildVaultOption(
              icon: Icons.timer_outlined,
              label: 'Crear pendiente',
              sublabel: 'Recordatorio para tramitarlo después',
              onTap: () {
                Navigator.pop(ctx);
                _simulateSaveToVault(context, 'Pendiente creado');
              },
            ),
             const SizedBox(height: 16),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildVaultOption({required IconData icon, required String label, required String sublabel, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  Text(sublabel, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30),
          ],
        ),
      ),
    );
  }

  void _simulateSaveToVault(BuildContext context, String actionType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF151C2B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(10), 
           side: const BorderSide(color: Color(0xFFD4AF37), width: 1)
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFD4AF37)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Guardado en Bóveda ✅', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('$actionType correctamente', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VER',
          textColor: const Color(0xFFD4AF37),
          onPressed: () {
             // Navigate to vault if implemented
          },
        ),
      ),
    );
  }
}
