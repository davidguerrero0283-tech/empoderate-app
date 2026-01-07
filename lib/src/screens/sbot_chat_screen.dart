import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../sbot/ai_model.dart';

class SBotChatScreen extends StatelessWidget {
  final AiPersonality personality;
  final String initialPrompt;

  const SBotChatScreen({
    Key? key,
    required this.personality,
    required this.initialPrompt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Chat IA',
      showBackButton: true,
      body: Center(
        child: Text(
          'Chat screen placeholder for "${personality.name}".\nInitial prompt: $initialPrompt',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
