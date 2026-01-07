import 'package:flutter/material.dart';
import '../components/premium_scaffold.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';

class ContentDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String content;

  const ContentDetailScreen({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: title.toUpperCase(),
      showBackButton: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: EmpoderateTheme.titleStyle.copyWith(
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: EmpoderateTheme.subtitleStyle.copyWith(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          // Main Content
          Text(
            content,
            style: EmpoderateTheme.bodyStyle.copyWith(
              fontSize: 16,
              height: 1.6, 
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 40),
          // Back Button
          Center(
            child: SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  'Volver',
                  style: EmpoderateTheme.titleStyle.copyWith(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
