import 'package:flutter/material.dart';
import '../../components/premium_scaffold.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../calculators/liquidacion_models.dart';
import '../../utils/carta_generator.dart';
import '../../components/neon_widgets.dart'; // Ensure consistency
import '../../services/pdf_service.dart';

class CartaPreviewScreen extends StatefulWidget {
  final LiquidacionInputModel input;
  final LiquidacionResultModel result;
  final bool isCarta;
  final String? customContent;
  final String? customTitle;

  const CartaPreviewScreen({
    Key? key,
    required this.input,
    required this.result,
    this.isCarta = true,
    this.customContent,
    this.customTitle,
  }) : super(key: key);

  @override
  _CartaPreviewScreenState createState() => _CartaPreviewScreenState();
}

class _CartaPreviewScreenState extends State<CartaPreviewScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    String generated = '';
    try {
      if (widget.customContent != null) {
        generated = widget.customContent!;
      } else {
        generated = widget.isCarta 
            ? CartaGenerator.generateLetter(widget.input, widget.result)
            : CartaGenerator.generateReceipt(widget.input, widget.result);
      }
      
      if (generated.isEmpty || generated.trim().isEmpty) {
        generated = "⚠️ El contenido del documento está vacío.\n\nPor favor verifique los datos.";
      }
    } catch (e) {
      generated = "Error al generar el documento:\n$e";
    }
    _controller = TextEditingController(text: generated);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: widget.customTitle ?? (widget.isCarta ? 'VISTA PREVIA DE CARTA' : 'COMPROBANTE'),
      showBackButton: true,
      useScroll: false, // Flexible requires bounded height
      body: Container(
        color: const Color(0xFF001225), // Background of the app theme
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800), 
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      readOnly: true, // Make it read-only for preview
                      style: GoogleFonts.notoSans( 
                        color: Colors.black,
                        fontSize: 14, 
                        height: 1.6,
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Actions at bottom
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF001225),
        border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // PRIMARY SAVE ACTION
            SizedBox(
              width: double.infinity,
              child: NeonButton(
                text: widget.isCarta ? 'Guardar Carta' : 'Guardar Comprobante',
                icon: Icons.save,
                primary: true,
                color: const Color(0xFFD4AF37),
                textColor: Colors.black,
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Guardado exitosamente (Simulado).'), backgroundColor: Colors.green)
                   );
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // SECONDARY ACTIONS - EXPORT ROW
            Row(
              children: [
                Expanded(
                  child: NeonButton(
                    text: 'Exportar PDF',
                    icon: Icons.picture_as_pdf,
                    primary: false,
                    onTap: () => _mockExport('PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeonButton(
                    text: 'Exportar Word',
                    icon: Icons.description, // Word-like icon
                    primary: false,
                    onTap: () => _mockExport('Word'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // SHARE ACTION
            SizedBox(
              width: double.infinity,
              child: NeonButton(
                text: 'Compartir',
                icon: Icons.share,
                primary: false,
                onTap: () {
                   // Share logic
                   Share.share(_controller.text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mockExport(String format) async {
    if (format == 'PDF') {
      try {
        if (widget.isCarta) {
           await PdfService.generateLetterPdf(widget.input, widget.result);
        } else {
           await PdfService.generateLiquidacionPdf(widget.input, widget.result);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generando archivo $format...'), duration: const Duration(milliseconds: 800)),
    );
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Archivo $format exportado exitosamente (Simulado).'),
          backgroundColor: const Color(0xFFD4AF37),
        ),
      );
    }
  }
}
