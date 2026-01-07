
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../calculators/salario_models.dart';
import '../calculators/liquidacion_models.dart';

class PdfService {
  static final _currencyFormat = NumberFormat("#,##0.00", "en_US");
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  /// Generates and prints/shares a PDF for Planilla Receipt
  static Future<void> generatePlanillaPdf(SalarioInputModel input, SalarioResultModel result) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('COMPROBANTE DE PAGO', input.companyName),
              pw.SizedBox(height: 20),
              _buildInfoRow('Colaborador:', input.workerName),
              _buildInfoRow('Cargo:', input.position),
              _buildInfoRow('Periodo:', '${_dateFormat.format(input.periodStart)} - ${_dateFormat.format(input.periodEnd)}'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildSectionTitle('INGRESOS'),
              _buildRow('Salario Base', result.baseIncome),
              if(result.overtimeDaytimeAmount > 0) _buildRow('Horas Extra Diurnas', result.overtimeDaytimeAmount),
              if(result.overtimeNightAmount > 0) _buildRow('Horas Extra Nocturnas', result.overtimeNightAmount),
              if(result.overtimeMixedAmount > 0) _buildRow('Horas Extra Mixtas', result.overtimeMixedAmount),
              if(result.sundayAmount > 0) _buildRow('Domingos', result.sundayAmount),
              if(result.holidayAmount > 0) _buildRow('Feriados', result.holidayAmount),
              if(result.nightSurchargeAmount > 0) _buildRow('Recargo Nocturno', result.nightSurchargeAmount),
              if(result.commissionsAmount > 0) _buildRow('Comisiones', result.commissionsAmount),
              if(result.bonusesAmount > 0) _buildRow('Bonificaciones', result.bonusesAmount),
              pw.SizedBox(height: 5),
              _buildTotalRow('TOTAL DEVENGADO', result.totalDevengado),
              
              pw.SizedBox(height: 15),
              _buildSectionTitle('DEDUCCIONES'),
              _buildRow('Seguro Social', result.css),
              _buildRow('Seguro Educativo', result.se),
              _buildRow('Impuesto Renta', result.isr),
              if(result.otherDeductions > 0) _buildRow('Otras Deducciones', result.otherDeductions),
              pw.SizedBox(height: 5),
              _buildTotalRow('TOTAL DEDUCCIONES', result.totalDeducciones, isNegative: true),
              
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('NETO A PAGAR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text('\$${_currencyFormat.format(result.netSalary)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   pw.Container(width: 200, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())), child: pw.Center(child: pw.Text('Firma Empleador', style: const pw.TextStyle(fontSize: 10)))),
                   pw.Container(width: 200, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())), child: pw.Center(child: pw.Text('Firma Colaborador', style: const pw.TextStyle(fontSize: 10)))),
                ]
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  /// Generates Liquidacion Receipt PDF
  static Future<void> generateLiquidacionPdf(LiquidacionInputModel input, LiquidacionResultModel result) async {
     final doc = pw.Document();
     doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (pw.Context context) {
           return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('LIQUIDACIÓN DE PRESTACIONES', input.companyName),
              pw.SizedBox(height: 15),
              _buildInfoRow('Colaborador:', input.workerName),
              _buildInfoRow('Cédula:', input.workerId),
              if (input.department != null && input.department!.isNotEmpty) _buildInfoRow('Departamento:', input.department!),
              _buildInfoRow('Fecha Ingreso:', _dateFormat.format(input.startDate)),
              _buildInfoRow('Fecha Salida:', _dateFormat.format(input.endDate)),
              _buildInfoRow('Tiempo Laborado:', '${result.yearsWorked} años, ${result.monthsWorked} meses, ${result.daysWorked} días'),
              pw.SizedBox(height: 15),
              pw.Divider(),
              
              _buildSectionTitle('DERECHOS ADQUIRIDOS'),
              if((result.salarioAdeudado ) > 0) _buildRow('Salario Pendiente', result.salarioAdeudado),
              _buildRow('Vacaciones Vencidas', result.vacacionesVencidas),
              _buildRow('Vacaciones Proporcionales', result.vacacionesProporcionales),
              _buildRow('Décimo Tercer Mes', result.decimoProporcional),
              
              pw.SizedBox(height: 10),
              _buildSectionTitle('INDEMNIZACIÓN (Si aplica)'),
              _buildRow('Prima Antigüedad', result.primaAntiguedad),
              _buildRow('Indemnización Despido', result.indemnizacion),
              if(result.preaviso > 0) _buildRow('Preaviso', result.preaviso),

              pw.SizedBox(height: 5),
              _buildTotalRow('SUBTOTAL INGRESOS', result.subtotalDevengos),
              
              pw.SizedBox(height: 15),
              _buildSectionTitle('DEDUCCIONES'),
              _buildRow('Seguro Social', result.css + result.cssSalario + result.cssVacaciones + result.cssDecimo + result.cssPreaviso), 
              _buildRow('Seguro Educativo', result.se + result.seSalario + result.seVacaciones + result.seDecimo + result.sePreaviso),
              _buildRow('Impuesto Renta', result.isr + result.isrPreaviso),
              if(result.otherDeductionsDetailed > 0) _buildRow('Otros Descuentos', result.otherDeductionsDetailed),
              
              pw.SizedBox(height: 5),
              _buildTotalRow('TOTAL DEDUCCIONES', result.totalDeducciones, isNegative: true),
              
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL A RECIBIR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text('\$${_currencyFormat.format(result.totalPagar)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
               pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   pw.Container(width: 200, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())), child: pw.Center(child: pw.Text('Firma Empleador', style: const pw.TextStyle(fontSize: 10)))),
                   pw.Container(width: 200, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())), child: pw.Center(child: pw.Text('Recibí Conforme (Trabajador)', style: const pw.TextStyle(fontSize: 10)))),
                ]
              ),
              pw.SizedBox(height: 20),
            ]
           );
        }
      )
     );
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  /// Generates a generic professionally styled PDF from text (for vacations, permissions, etc.)
  static Future<void> generateGenericDocument({
    required String title,
    required String content,
    String? companyName,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(title, companyName ?? 'EMPRESA'),
              pw.SizedBox(height: 40),
              pw.Text(content, 
                style: pw.TextStyle(fontSize: 12, lineSpacing: 5),
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }
  
  /// Generates Letter (Carta de Trabajo / Despido)
  static Future<void> generateLetterPdf(LiquidacionInputModel input, LiquidacionResultModel result) async {
     final doc = pw.Document();
     
     // Basic text based on termination type (Simplified mapping)
     String title = 'CARTA DE TERMINACÍON';

     // Ideally we would reuse CartaGenerator text logic here, but need to adapt to PDF widgets.
     // For now, let's create a simplified professional layout.
     
     doc.addPage(
       pw.Page(
         pageFormat: PdfPageFormat.letter,
         build: (pw.Context context) {
           return pw.Column(
             crossAxisAlignment: pw.CrossAxisAlignment.start,
             children: [
               _buildHeader(title, input.companyName),
               pw.SizedBox(height: 40),
               pw.Text('Fecha: ${_dateFormat.format(DateTime.now())}'),
               pw.SizedBox(height: 20),
               pw.Text('Señor(a): ${input.workerName}'),
               pw.Text('Cédula: ${input.workerId}'),
               pw.SizedBox(height: 20),
               pw.Text('Estimado(a) colaborador(a):', style: const pw.TextStyle(fontSize: 12)),
               pw.SizedBox(height: 10),
               pw.Text(
                 'Por este medio le comunicamos la terminación de su contrato de trabajo por motivo de: ${input.terminationType.toString().split('.').last}. \n\n'
                 'Su último día de labores fue el ${_dateFormat.format(input.endDate)}. Agradecemos el tiempo brindado a la empresa durante el periodo del ${_dateFormat.format(input.startDate)} al ${_dateFormat.format(input.endDate)}.\n\n'
                 'Adjunto encontrará el desglose de su liquidación de conformidad con las leyes vigentes.',
                 textAlign: pw.TextAlign.justify,
                 style: const pw.TextStyle(fontSize: 12, lineSpacing: 5),
               ),
               pw.SizedBox(height: 60),
               pw.Text('Atentamente,'),
               pw.SizedBox(height: 40),
               pw.Container(width: 200, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())), child: pw.Padding(padding: const pw.EdgeInsets.only(top: 5), child: pw.Text(input.companyName))),
             ]
           );
         }
       )
     );
     
     await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  // --- Helpers ---

  static pw.Widget _buildHeader(String title, String company) {
    return pw.Column(
      children: [
        if(company.isNotEmpty) pw.Text(company.toUpperCase(), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(title, style: const pw.TextStyle(fontSize: 14)),
        pw.Divider(thickness: 2),
      ]
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 100, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ]
      )
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline))
    );
  }

  static pw.Widget _buildRow(String label, double val) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(_currencyFormat.format(val), style: const pw.TextStyle(fontSize: 10)),
        ]
      )
    );
  }
  
  static pw.Widget _buildTotalRow(String label, double val, {bool isNegative = false}) {
     return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.Text('${isNegative ? "-" : ""}${_currencyFormat.format(val)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ]
      );
  }

  /// Generates Vacation Receipt PDF
  static Future<void> generateVacacionesPdf({
    required String workerName,
    required String companyName,
    required DateTime serviceStart,
    required DateTime serviceEnd,
    required int diasVacaciones,
    required double salarioPromedio,
    required double montoVacaciones,
    required double deduccionCSS,
    required double deduccionSE,
    required double deduccionISR,
    required double netoVacaciones,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('COMPROBANTE DE PAGO DE VACACIONES', companyName),
              pw.SizedBox(height: 20),
              _buildInfoRow('Colaborador:', workerName),
              _buildInfoRow('Inicio Relación:', _dateFormat.format(serviceStart)),
              _buildInfoRow('Corte Cálculo:', _dateFormat.format(serviceEnd)),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildSectionTitle('CÁLCULO DE VACACIONES'),
              _buildInfoRow('Días de Vacaciones:', '$diasVacaciones días'),
              _buildInfoRow('Salario Promedio Diario:', 'B/. ${_currencyFormat.format(salarioPromedio)}'),
              pw.SizedBox(height: 10),
              _buildTotalRow('MONTO BRUTO VACACIONES', montoVacaciones),
              
              pw.SizedBox(height: 15),
              _buildSectionTitle('DEDUCCIONES'),
              _buildRow('Seguro Social (9.75%)', deduccionCSS),
              _buildRow('Seguro Educativo (1.25%)', deduccionSE),
              if (deduccionISR > 0) _buildRow('Impuesto Renta', deduccionISR),
              pw.SizedBox(height: 5),
              _buildTotalRow('TOTAL DEDUCCIONES', deduccionCSS + deduccionSE + deduccionISR, isNegative: true),
              
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('NETO A RECIBIR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text('B/. ${_currencyFormat.format(netoVacaciones)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   pw.Container(width: 200, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())), child: pw.Center(child: pw.Text('Firma Empleador', style: const pw.TextStyle(fontSize: 10)))),
                   pw.Container(width: 200, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())), child: pw.Center(child: pw.Text('Firma Colaborador', style: const pw.TextStyle(fontSize: 10)))),
                ]
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  /// Generates Décimo Tercer Mes Receipt PDF
  static Future<void> generateDecimoPdf({
    required String workerName,
    required String companyName,
    required int partida,
    required int year,
    required List<String> periodLabels,
    required List<double> earnings,
    required double totalGanancias,
    required double decimoBruto,
    required double deduccionCSS,
    required double deduccionSE,
    required double deduccionISR,
    required double decimoNeto,
  }) async {
    final doc = pw.Document();
    
    String partidaLabel = partida == 1 ? '1ª Partida (Abril 15)' : 
                          partida == 2 ? '2ª Partida (Agosto 15)' : 
                          '3ª Partida (Diciembre 15)';
    
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('COMPROBANTE DE DÉCIMO TERCER MES', companyName),
              pw.SizedBox(height: 20),
              _buildInfoRow('Colaborador:', workerName),
              _buildInfoRow('Año:', year.toString()),
              _buildInfoRow('Partida:', partidaLabel),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildSectionTitle('GANANCIAS DEL PERÍODO'),
              ...List.generate(4, (i) => _buildRow(periodLabels[i], earnings[i])),
              pw.SizedBox(height: 5),
              _buildTotalRow('TOTAL GANANCIAS', totalGanancias),
              
              pw.SizedBox(height: 10),
              _buildSectionTitle('CÁLCULO DEL DÉCIMO'),
              _buildInfoRow('Fórmula:', 'Total Ganancias ÷ 12'),
              pw.SizedBox(height: 5),
              _buildTotalRow('DÉCIMO BRUTO', decimoBruto),
              
              pw.SizedBox(height: 15),
              _buildSectionTitle('DEDUCCIONES'),
              _buildRow('Seguro Social (7.25%)', deduccionCSS),
              if (deduccionSE > 0) _buildRow('Seguro Educativo', deduccionSE),
              if (deduccionISR > 0) _buildRow('Impuesto Renta', deduccionISR),
              pw.SizedBox(height: 5),
              _buildTotalRow('TOTAL DEDUCCIONES', deduccionCSS + deduccionSE + deduccionISR, isNegative: true),
              
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('DÉCIMO NETO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text('B/. ${_currencyFormat.format(decimoNeto)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   pw.Container(width: 200, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())), child: pw.Center(child: pw.Text('Firma Empleador', style: const pw.TextStyle(fontSize: 10)))),
                   pw.Container(width: 200, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())), child: pw.Center(child: pw.Text('Firma Colaborador', style: const pw.TextStyle(fontSize: 10)))),
                ]
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }
}
