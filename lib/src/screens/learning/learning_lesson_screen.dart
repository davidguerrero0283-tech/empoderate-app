import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/premium_scaffold.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import 'learning_models.dart';

class LearningLessonScreen extends StatelessWidget {
  final LearningLesson lesson;

  const LearningLessonScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'LECCIÓN',
      showBackButton: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.title,
            style: EmpoderateTheme.titleStyle.copyWith(
               fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.subtitle,
            style: EmpoderateTheme.subtitleStyle.copyWith(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            lesson.content,
            style: EmpoderateTheme.bodyStyle.copyWith(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          // Placeholder for Examples/Images
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: EmpoderateTheme.glass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Center(
              child: Text(
                'Espacio para ejemplos o imágenes',
                style: EmpoderateTheme.subtitleStyle.copyWith(color: Colors.white38),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lección marcada como leída')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: EmpoderateTheme.goldStrong,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Marcar como leído',
                style: EmpoderateTheme.titleStyle.copyWith(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Volver',
                style: EmpoderateTheme.titleStyle.copyWith(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
