import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../components/premium_scaffold.dart';
import '../../components/premium_cards.dart'; // ComponenteTarjetaPremium
import 'learning_models.dart';
import 'learning_lesson_screen.dart';
import '../../components/info_button.dart';

class LearningCategoryScreen extends StatelessWidget {
  final LearningCategory category;

  const LearningCategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'CURSOS',
      showBackButton: true,
      floatingActionButton: (category.infoTitle != null && category.infoContent != null)
          ? InfoButton(
              title: category.infoTitle!,
              content: category.infoContent!,
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Text(
            category.title,
            style: GoogleFonts.outfit(
              color: category.color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.subtitle,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Lesson List (Style A)
          if (category.lessons.isEmpty)
            const Center(child: Text('Próximamente', style: TextStyle(color: Colors.white54))),
          
          ...category.lessons.map((lesson) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ComponenteTarjetaPremium(
              icon: category.icon, 
              title: lesson.title,
              subtitle: lesson.subtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LearningLessonScreen(lesson: lesson),
                  ),
                );
              },
              iconColor: category.color,
            ),
          )).toList(),
        ],
      ),
    );
  }
}
