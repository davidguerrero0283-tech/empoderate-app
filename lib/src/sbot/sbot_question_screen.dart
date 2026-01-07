import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/components/header/premium_header.dart';
import '../components/gradient_background.dart';
import '../navigation/app_routes.dart';
import 'sbot_components.dart';

class SBotQuestionScreen extends StatefulWidget {
  const SBotQuestionScreen({Key? key}) : super(key: key);

  @override
  State<SBotQuestionScreen> createState() => _SBotQuestionScreenState();
}

class _SBotQuestionScreenState extends State<SBotQuestionScreen> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    if (_controller.text.trim().isNotEmpty) {
      Navigator.pushNamed(context, AppRoutes.sbotResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: PremiumHeader(showBackButton: true),
      ),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '¿Qué deseas entender o resolver?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Ejemplo: ¿Qué necesito para abrir un restaurante?',
                          style: GoogleFonts.outfit(
                            color: Colors.white54,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SbotInputBox(
                controller: _controller,
                hintText: 'Escribe tu consulta aquí...',
                onSend: _handleSend,
              ),
              const SizedBox(height: 16),
              SbotPrimaryButton(
                text: 'Enviar',
                onPressed: _handleSend,
              ),
              const SizedBox(height: 16), // Bottom safe area
            ],
          ),
        ),
      ),
    );
  }
}
