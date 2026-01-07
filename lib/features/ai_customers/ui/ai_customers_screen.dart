import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/features/ai_customers/domain/ai_customer_request.dart';
import 'package:proyecto_empoderate/features/ai_customers/domain/ai_customer_output.dart';
import 'package:proyecto_empoderate/features/ai_customers/data/ai_customers_service.dart';
import 'widgets/customer_request_form.dart';
import 'widgets/customer_output_card.dart';

class AiCustomersScreen extends StatefulWidget {
  const AiCustomersScreen({Key? key}) : super(key: key);

  @override
  State<AiCustomersScreen> createState() => _AiCustomersScreenState();
}

class _AiCustomersScreenState extends State<AiCustomersScreen> {
  final AiCustomersService _service = AiCustomersService();
  bool _isLoading = false;
  bool _isSaving = false;
  AiCustomerOutput? _currentOutput;
  AiCustomerRequest? _lastRequest;

  Future<void> _generate(AiCustomerRequest request) async {
    setState(() {
      _isLoading = true;
      _lastRequest = request;
    });

    try {
      final output = await _service.generate(request);
      setState(() {
        _currentOutput = output;
        _isLoading = false;
      });
      
      // Auto-scroll to results
      Future.delayed(const Duration(milliseconds: 300), () {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al generar estrategia. Intenta de nuevo.')),
      );
    }
  }

  Future<void> _save() async {
    if (_currentOutput == null) return;
    
    setState(() => _isSaving = true);
    try {
      await _service.save(_currentOutput!);
      setState(() => _isSaving = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Estrategia guardada con éxito!'),
          backgroundColor: Colors.cyanAccent,
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'IA PARA CLIENTES',
      subtitle: 'Estrategias maestras de conexión',
      body: Column(
        children: [
          // HEADER EXPLANATION
          NeonWideCard(
            borderColor: Colors.cyanAccent,
            child: Row(
              children: [
                const Icon(Icons.people_alt, color: Colors.cyanAccent, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conoce a tu cliente ideal',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ingresa una idea o datos sobre tu cliente y nuestra IA generará su perfil y una estrategia de conexión.',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // GENERATION FORM
          AiCustomerRequestForm(
            onGenerate: _generate,
            isLoading: _isLoading,
          ),
          
          // RESULTS SECTION
          if (_currentOutput != null) ...[
            const SizedBox(height: 40),
            const Divider(color: Colors.cyanAccent, thickness: 1),
            const SizedBox(height: 20),
            
            AiCustomerOutputCard(
              output: _currentOutput!,
              onSave: _save,
              onRegenerate: () => _generate(_lastRequest!),
              isSaving: _isSaving,
            ),
          ],
          
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
