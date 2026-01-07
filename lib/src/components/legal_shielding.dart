import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ShieldType {
  ai,
  tramites,
  calculators,
  docs,
  general,
}

class LegalShielding extends StatelessWidget {
  final ShieldType type;
  final EdgeInsetsGeometry padding;

  const LegalShielding({
    Key? key,
    required this.type,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
  }) : super(key: key);

  String get _text {
    switch (type) {
      case ShieldType.ai:
        return 'Esta herramienta utiliza Inteligencia Artificial para generar información orientativa. No reemplaza la asesoría de un contador, abogado o especialista. Verifique siempre la información antes de usarla.';
      case ShieldType.tramites:
        return 'Los requisitos pueden variar según municipio o cambios legales. Esta información es orientativa. Confirma siempre en las instituciones oficiales.';
      case ShieldType.calculators:
        return 'Los resultados son aproximados y no sustituyen la revisión de un contador público autorizado (CPA). Verifica las normativas vigentes.';
      case ShieldType.docs:
        return 'Los documentos generados son borradores sugeridos por IA. No sustituyen la asesoría legal profesional.';
      case ShieldType.general:
        return 'Esta información es orientativa y puede requerir verificación adicional.';
    }
  }

  @override
  Widget build(BuildContext context) {
    const kNeonGold = Color(0xFFF4D35E);

    return Padding(
      padding: padding,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1929).withOpacity(0.6), // Dark translucent
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kNeonGold.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: kNeonGold.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: kNeonGold, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _text,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
