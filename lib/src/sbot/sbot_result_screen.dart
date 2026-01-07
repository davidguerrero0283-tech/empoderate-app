import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/components/header/premium_header.dart';
import '../components/gradient_background.dart';
import '../navigation/app_routes.dart';
import 'sbot_components.dart';
import 'sbot_service_placeholder.dart';

class SBotResultScreen extends StatefulWidget {
  const SBotResultScreen({Key? key}) : super(key: key);

  @override
  State<SBotResultScreen> createState() => _SBotResultScreenState();
}

class _SBotResultScreenState extends State<SBotResultScreen> {
  final SbotServicePlaceholder _service = SbotServicePlaceholder();
  String? _result;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    final response = await _service.processQuery("query placeholder");
    if (mounted) {
      setState(() {
        _result = response;
        _isLoading = false;
      });
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                  color: const Color(0xFF001B3A),
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.lightbulb, size: 40, color: Color(0xFFD4AF37)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Resultado de tu consulta',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: SbotLoader())
              else
                SbotBubbleBot(text: _result ?? ''),
              const SizedBox(height: 32),
              SbotPrimaryButton(
                text: 'Nueva consulta',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.sbotQuestion, ModalRoute.withName(AppRoutes.sbot)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // Placeholder for save history
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Guardado en historial (placeholder)')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'Guardar en historial',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFD4AF37),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
