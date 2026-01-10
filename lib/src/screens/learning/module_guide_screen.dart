import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../ui/theme/empoderate_theme.dart';
import '../../components/premium_scaffold.dart';
import 'module_guide_data.dart';
import '../../features/mi_negocio_rubro/ui/tramite_detail_screen.dart'; // Reusing premium logic if needed
import 'rubro_selector_questionnaire.dart';

class ModuleGuideScreen extends StatelessWidget {
  const ModuleGuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SAFE RESOLVER - No dangerous casts
    final ModuleGuideData args = _getModuleData(context);

    return PremiumScaffold(
      title: args.title.toUpperCase(),
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: EmpoderateTheme.safeBoxDecoration(
                gradient: LinearGradient(
                  colors: [args.themeColor.withOpacity(0.2), Colors.black],
                  begin: Alignment.topLeft, end: Alignment.bottomRight
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: args.themeColor.withOpacity(0.5)),
                boxShadow: [BoxShadow(color: args.themeColor.withOpacity(0.1), blurRadius: 20)],
              ),
              child: Row(
                children: [
                  Icon(args.icon, size: 48, color: args.themeColor),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(args.subtitle, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Guía Oficial Empodérate', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // NEW: Call to Action for Questionnaire (Only for Start Guide)
            if (args.id == 'start') // Using args.id as guideId
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Launch Questionnaire
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const RubroSelectorQuestionnaire()),
                    );
                  },
                  icon: const Icon(Icons.quiz, color: Colors.blueAccent),
                  label: Text('Realizar Test de Compatibilidad', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            
            // Use .map().toList() to build children list
            ...args.sections.map((section) => Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.title, style: GoogleFonts.outfit(color: args.themeColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (section.content.isNotEmpty)
                    Text(section.content, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, height: 1.6)),
                  
                  if (section.bullets != null) ...[
                     const SizedBox(height: 12),
                     ...section.bullets!.map((bullet) => Padding(
                       padding: const EdgeInsets.only(bottom: 8),
                       child: Row(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Text('• ', style: TextStyle(color: Colors.white54, fontSize: 16)),
                           Expanded(child: Text(bullet, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, height: 1.5))),
                         ],
                       ),
                     )),
                  ]
                ],
              ),
            )), // No toList needed with spread operator if type inference works, but safer with map(...).toList() sometimes. 
            // In Flutter DSL spread operator works fine on Iterables.

            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: args.themeColor.withOpacity(0.2),
                  foregroundColor: args.themeColor,
                  side: BorderSide(color: args.themeColor),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('ENTENDIDO'),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
  
  /// Safely extracts ModuleGuideData from route arguments
  /// Returns fallback if data is missing or invalid type
  ModuleGuideData _getModuleData(BuildContext context) {
    final route = ModalRoute.of(context);
    
    // Check if arguments are of correct type
    if (route?.settings.arguments is ModuleGuideData) {
      return route!.settings.arguments as ModuleGuideData;
    }
    
    // Fallback for invalid or missing data
    return ModuleGuideData(
      id: 'fallback',
      title: 'Contenido No Disponible',
      subtitle: 'Esta guía está en construcción',
      themeColor: Color(0xFF666666),
      icon: Icons.construction,
      sections: [
        GuideSection(
          title: 'Información Temporal',
          content: 'El contenido de esta guía se está preparando. Por favor, vuelve más tarde o contacta con soporte si este mensaje persiste.',
        ),
      ],
    );
  }
}
