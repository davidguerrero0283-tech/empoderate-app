import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/components/header/premium_header.dart';
import '../components/gradient_background.dart';
import '../components/section_option_card.dart';
import '../components/premium_placeholders.dart';
import '../navigation/app_routes.dart';
import 'sbot_components.dart';
import 'ai_model.dart';
import 'sbot_chat_screen.dart';

class SBotHomeScreen extends StatelessWidget {
  const SBotHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(110),
        child: PremiumHeader(showBackButton: true),
      ),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.only(top: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Centro de Inteligencia',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFD4AF37),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona un experto para trabajar en tu negocio.',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: empoderateAIs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final ai = empoderateAIs[index];
                    return SectionOptionCard(
                      icon: ai.icon,
                      title: ai.name,
                      subtitle: ai.role,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SBotChatScreen(personality: ai),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaceholderMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente, S-BOT te guiará paso a paso en esta sección.'),
        backgroundColor: Color(0xFF001B3A),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
