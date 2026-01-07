import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'fixed_costs_models.dart';

class FixedCostsExportService {
  
  // --- PDF EXPORT ---
  static Future<void> exportPdf(FixedCostsScenario scenario) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.outfitRegular();
    final fontBold = await PdfGoogleFonts.outfitBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return [
            _buildPdfHeader(scenario),
            pw.SizedBox(height: 20),
            _buildPdfKpi(scenario),
            pw.SizedBox(height: 20),
            _buildPdfTable(scenario),
            pw.SizedBox(height: 20),
            _buildPdfCategorySummary(scenario),
            pw.SizedBox(height: 40),
            _buildPdfFooter(),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'costos_fijos_${scenario.name.replaceAll(' ', '_')}.pdf');
  }

  static pw.Widget _buildPdfHeader(FixedCostsScenario scenario) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('EMPODÉRATE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
        pw.Text('Reporte de Costos Fijos (Overhead)', style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
        pw.SizedBox(height: 10),
        pw.Text('Escenario: ${scenario.name}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey500)),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildPdfKpi(FixedCostsScenario scenario) {
    final f = NumberFormat("#,##0.00", "en_US");
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _kpiBox('Total Mensual', '\$${f.format(scenario.totalMonthly)}'),
        _kpiBox('Total Anual', '\$${f.format(scenario.totalAnnual)}'),
        _kpiBox('Diario Aprox.', '\$${f.format(scenario.dailyEquivalent)}'),
      ],
    );
  }

  static pw.Widget _kpiBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(4)),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfTable(FixedCostsScenario scenario) {
    final headers = ['Nombre', 'Categoría', 'Frecuencia', 'Monto', 'Mensual Eq.'];
    final data = scenario.items.map((item) {
      return [
        item.name,
        item.category,
        item.frequency.label,
        '\$${item.amount.toStringAsFixed(2)}',
        '\$${item.monthlyEquivalent.toStringAsFixed(2)}'
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.centerLeft,
    );
  }

  static pw.Widget _buildPdfCategorySummary(FixedCostsScenario scenario) {
     final Map<String, double> breakdown = {};
     for (var i in scenario.items) {
       breakdown[i.category] = (breakdown[i.category] ?? 0) + i.monthlyEquivalent;
     }
     final sorted = breakdown.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
     
     return pw.Column(
       crossAxisAlignment: pw.CrossAxisAlignment.start,
       children: [
         pw.Text('Resumen por Categoría', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
         pw.SizedBox(height: 8),
         ...sorted.map((e) => pw.Row(
           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
           children: [
             pw.Text(e.key, style: const pw.TextStyle(fontSize: 10)),
             pw.Text('\$${e.value.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
           ],
         )).toList(),
       ],
     );
  }

  static pw.Widget _buildPdfFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text('Herramienta informativa. No sustituye asesoría contable/financiera.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
      ]
    );
  }

  // --- WORD / DOCX EXPORT (HTML Fallback) ---
  
  static Future<void> exportDocx(FixedCostsScenario scenario) async {
    // Generates an HTML file renamed to .doc, widely compatible
    final StringBuffer html = StringBuffer();
    final f = NumberFormat("#,##0.00", "en_US");
    
    html.writeln('<html><body>');
    html.writeln('<h1 style="color:teal;">Empodérate - Reporte de Costos Fijos</h1>');
    html.writeln('<p><strong>Escenario:</strong> ${scenario.name}<br><strong>Fecha:</strong> ${DateFormat('dd/MM/yyyy').format(DateTime.now())}</p>');
    html.writeln('<hr>');
    
    html.writeln('<h2>KPIs</h2>');
    html.writeln('<ul>');
    html.writeln('<li><strong>Total Mensual:</strong> \$${f.format(scenario.totalMonthly)}</li>');
    html.writeln('<li><strong>Total Anual:</strong> \$${f.format(scenario.totalAnnual)}</li>');
    html.writeln('<li><strong>Diario Aprox:</strong> \$${f.format(scenario.dailyEquivalent)}</li>');
    html.writeln('</ul>');
    
    html.writeln('<h2>Detalle de Costos</h2>');
    html.writeln('<table border="1" style="border-collapse: collapse; width: 100%;">');
    html.writeln('<tr style="background-color: #eee;"><th>Nombre</th><th>Categoría</th><th>Frecuencia</th><th>Monto</th><th>Mensual Eq.</th></tr>');
    
    for (var item in scenario.items) {
      html.writeln('<tr>');
      html.writeln('<td>${item.name}</td>');
      html.writeln('<td>${item.category}</td>');
      html.writeln('<td>${item.frequency.label}</td>');
      html.writeln('<td>\$${item.amount.toStringAsFixed(2)}</td>');
      html.writeln('<td>\$${item.monthlyEquivalent.toStringAsFixed(2)}</td>');
      html.writeln('</tr>');
    }
    html.writeln('</table>');
    
    html.writeln('<p style="font-size: 10px; color: grey;">Herramienta informativa. No sustituye asesoría.</p>');
    html.writeln('</body></html>');

    final String filename = 'costos_fijos_report.doc';
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(html.toString());
    
    await Share.shareXFiles([XFile(file.path)], text: 'Reporte de Costos Fijos');
  }

  // --- SHARE --
  static Future<void> shareSummary(FixedCostsScenario scenario) async {
    final f = NumberFormat("#,##0.00", "en_US");
    final String summary = '''
Empodérate - Costos Fijos
Escenario: ${scenario.name}

Total Mensual: \$${f.format(scenario.totalMonthly)}
Total Anual: \$${f.format(scenario.totalAnnual)}

Items:
${scenario.items.map((e) => '- ${e.name}: \$${e.monthlyEquivalent.toStringAsFixed(2)}/mes').join('\n')}
''';
    await Share.share(summary);
  }
}
