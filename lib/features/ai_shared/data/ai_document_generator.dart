import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../domain/ai_generic_output.dart';
import '../domain/ai_shared_types.dart';

class AiDocumentGenerator {
  Future<void> generateAndDownload(AiGenericOutput output) async {
    final pdf = pw.Document();
    
    // Load font (optional, using standard available fonts for now to be safe)
    // final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader(output),
            pw.SizedBox(height: 20),
            _buildContent(output),
            pw.SizedBox(height: 20),
            pw.Divider(),
            _buildFooter(output),
          ];
        },
      ),
    );

    // Prompt user to save/print
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Empoderate_IA_${output.request.type.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  pw.Widget _buildHeader(AiGenericOutput output) {
    String title = output.request.type.label;
    
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text("EMPODÉRATE", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.SizedBox(height: 5),
          pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
          pw.SizedBox(height: 5),
          pw.Text(output.request.prompt, style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)),
          pw.Divider(thickness: 2),
        ],
      ),
    );
  }

  pw.Widget _buildContent(AiGenericOutput output) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Resultado:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text(output.content, style: const pw.TextStyle(fontSize: 12, lineSpacing: 5)),
        pw.SizedBox(height: 20),
        if (output.extraInfo.isNotEmpty) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Información Adicional:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(output.extraInfo, style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildFooter(AiGenericOutput output) {
    return pw.Column(
      children: [
        pw.Text(
          "Generado por Empodérate IA - ${output.createdAt.toString()}",
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
        pw.Text(
          "Este documento es una sugerencia generada por Inteligencia Artificial. Revise con un experto.",
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
      ],
    );
  }
}
