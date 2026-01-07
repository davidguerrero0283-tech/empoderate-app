import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../../components/premium_scaffold.dart';
import 'learning_repository.dart';

class CourseModuleViewer extends StatelessWidget {
  final Course course;
  final CourseModule module;
  final int moduleIndex;

  const CourseModuleViewer({
    Key? key,
    required this.course,
    required this.module,
    required this.moduleIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'MÓDULO ${moduleIndex + 1}',
      showBackButton: true,
      useScroll: true,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
               module.title,
               style: GoogleFonts.outfit(
                 color: course.color,
                 fontSize: 24,
                 fontWeight: FontWeight.bold,
               ),
             ),
             const SizedBox(height: 12),
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: course.color.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(8),
                 border: Border(left: BorderSide(color: course.color, width: 3)),
               ),
               child: Text(module.description, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
             ),
             const SizedBox(height: 32),

             // RICH CONTENT
             // RICH CONTENT
             
             MarkdownBody(
               data: module.contentMarkdown,
               styleSheet: MarkdownStyleSheet(
                 p: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 16, height: 1.6),
                 h1: GoogleFonts.outfit(color: course.color, fontSize: 22, fontWeight: FontWeight.bold),
                 h2: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                 h3: GoogleFonts.outfit(color: course.color, fontSize: 18, fontWeight: FontWeight.bold),
                 strong: TextStyle(color: course.color, fontWeight: FontWeight.bold),
                 blockquote: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
                 listBullet: TextStyle(color: course.color),
                 code: TextStyle(color: Colors.amberAccent, backgroundColor: Colors.black45, fontFamily: 'Courier'),
               ),
             ),
             
             // Text(module.contentMarkdown, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),

             const SizedBox(height: 60),
             
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                  if (moduleIndex > 0)
                  OutlinedButton(
                    onPressed: () => context.pop(), 
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                    child: const Text('Anterio'),
                  )
                  else Spacer(),

                  ElevatedButton(
                    onPressed: () => context.pop(), // For now just pop, logic could be next
                    style: ElevatedButton.styleFrom(backgroundColor: course.color, foregroundColor: Colors.black),
                    child: const Text('Completar y Salir'),
                  ),
               ],
             ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
