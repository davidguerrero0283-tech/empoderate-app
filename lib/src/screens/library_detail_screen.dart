import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../components/legal_shielding.dart';

class LibraryDetailScreen extends StatelessWidget {
  final String categoryId;
  final Map<String, dynamic> categoryMeta;

  const LibraryDetailScreen({Key? key, required this.categoryId, required this.categoryMeta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color themeColor = categoryMeta['color'] as Color? ?? EmpoderateTheme.cyanAccent;
    // Map existing structure from categoryMeta or fetch if needed. For now assuming categoryMeta has title/files
    // In the new service, we passed 'title', 'icon', 'color'. 'files' might need to be fetched or passed.
    // Let's assume for MVP refactor, categoryMeta contains everything needed or we use a service.
    // Based on previous code, files were inside. 
    // Adapting to use categoryMeta as source of truth.
    
    String title = categoryMeta['title']?.toString().toUpperCase() ?? 'RECURSOS';
    List<dynamic> files = categoryMeta['files'] as List<dynamic>? ?? [];

    return PremiumScaffold(
      title: title,
      showBackButton: true,
      useScroll: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // B) INFO CARDS (Top)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildInfoCard(
                    '¿Qué es este recurso?',
                    'Esta colección contiene documentos esenciales para el área de $title, diseñados para simplificar tu gestión.',
                    Icons.help_outline,
                    themeColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    '¿Cómo usarlo?',
                    '1. Descarga el archivo.\n2. Edita los campos en azul.\n3. Guarda como PDF para enviar.',
                    Icons.check_circle_outline,
                    EmpoderateTheme.cyanAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // A) LISTA DE ARCHIVOS (TABLA VISUAL)
            Text('Archivos Disponibles', style: EmpoderateTheme.titleStyle.copyWith(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: EmpoderateTheme.deepBlue,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: themeColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildTableHeader(themeColor),
                  ...files.map((file) => _buildFileRow(file as Map<String, dynamic>, themeColor)).toList(),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // C) TABLA DE REQUISITOS (Mock)
            Text('Usos Frecuentes', style: EmpoderateTheme.titleStyle.copyWith(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 12),
            _buildUsageTable(themeColor),
            
            const SizedBox(height: 40),
            const LegalShielding(type: ShieldType.ai), 
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTableHeader(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Recurso', style: GoogleFonts.outfit(color: color, fontSize: 13, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('Descarga', style: GoogleFonts.outfit(color: color, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildFileRow(Map<String, dynamic> file, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3, 
            child: Row(
              children: [
                Icon(Icons.description, color: Colors.white54, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(file['name'], style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
                      Text('${file['format']} • ${file['size']}', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
                    ],
                  )
                ),
              ],
            )
          ),
          Expanded(
            flex: 1, 
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.download_rounded, color: color, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: color.withOpacity(0.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageTable(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
           Padding(
             padding: const EdgeInsets.all(12),
             child: Row(
               children: [
                 Expanded(child: Text('Documento', style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 13))),
                 Expanded(child: Text('Cuándo se usa', style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 13))),
               ],
             ),
           ),
           Divider(color: color.withOpacity(0.2), height: 1),
           Padding(
             padding: const EdgeInsets.all(12),
             child: Row(
               children: [
                 Expanded(child: Text('Contrato B2B', style: GoogleFonts.outfit(color: Colors.white, fontSize: 13))),
                 Expanded(child: Text('Al iniciar relación con cliente nuevo.', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13))),
               ],
             ),
           ),
        ],
      ),
    );
  }
}
