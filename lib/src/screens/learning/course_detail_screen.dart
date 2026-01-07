import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../ui/theme/empoderate_theme.dart';
import '../../components/premium_scaffold.dart';
import '../../components/legal_shielding.dart';
import 'learning_repository.dart';
import 'course_module_viewer.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color themeColor = course.color;

    return PremiumScaffold(
      title: course.title.length > 20 ? 'DETALLE DEL CURSO' : course.title.toUpperCase(),
      showBackButton: true,
      useScroll: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A) INTRODUCCIÓN
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: themeColor.withOpacity(0.5)),
                  ),
                  child: Icon(course.icon, size: 40, color: themeColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description,
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTag('Nivel: ${course.level}', Colors.blueAccent),
                          _buildTag('Duración: ${course.duration}', Colors.orangeAccent),
                          _buildTag('${course.modules.length} Módulos', Colors.greenAccent),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // B) MÓDULOS DE CURSO
            Text('Contenido del Curso', style: EmpoderateTheme.titleStyle.copyWith(fontSize: 18)),
            const SizedBox(height: 24),
            
            // DYNAMIC MODULES LIST
            ...List.generate(course.modules.length, (index) {
               return _buildModuleCard(context, index, course.modules[index], themeColor);
            }),
            
            if (course.modules.isEmpty)
              const Text('Próximamente más contenido.', style: TextStyle(color: Colors.white30)),
            
            const SizedBox(height: 48),

            // D) BLOQUE CÓMO USAR
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [EmpoderateTheme.purpleAccent.withOpacity(0.1), Colors.transparent]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: EmpoderateTheme.purpleAccent.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Estructura', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Text('Completa los módulos en orden para desbloquear el siguiente nivel de conocimiento. Al finalizar, intenta aplicar lo aprendido en la sección de Herramientas.', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 40),
            const LegalShielding(type: ShieldType.ai), 
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _buildModuleCard(BuildContext context, int index, CourseModule module, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EmpoderateTheme.deepBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text('${index + 1}', style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(module.description, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
               context.push('/learning_center/course/${course.id}/module/$index');
            }, 
            icon: Icon(Icons.play_circle_fill, color: color, size: 32)
          ),
        ],
      ),
    );
  }
}
