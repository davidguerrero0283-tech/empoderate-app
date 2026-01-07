
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../calculators/salario_models.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../business_profile/business_profile_models.dart';
import '../../services/business_service.dart';
import '../../features/boveda/services/boveda_service.dart';
import '../../features/boveda/models/doc_model.dart';

class ComprobantePlanillaScreen extends StatefulWidget {
  final SalarioInputModel input;
  final SalarioResultModel result;

  const ComprobantePlanillaScreen({Key? key, required this.input, required this.result}) : super(key: key);

  @override
  State<ComprobantePlanillaScreen> createState() => _ComprobantePlanillaScreenState();
}

class _ComprobantePlanillaScreenState extends State<ComprobantePlanillaScreen> {
  BusinessProfile? _companyProfile;
  
  // Editable Controllers
  late TextEditingController _companyNameCtrl;
  late TextEditingController _workerNameCtrl;
  late TextEditingController _positionCtrl;
  late TextEditingController _notesCtrl;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize with input data
    _companyNameCtrl = TextEditingController(text: widget.input.companyName);
    _workerNameCtrl = TextEditingController(text: widget.input.workerName);
    _positionCtrl = TextEditingController(text: widget.input.position);
    _notesCtrl = TextEditingController(text: '');
    
    _loadCompanyProfile();
  }

  Future<void> _loadCompanyProfile() async {
    final profile = await BusinessService().getProfile();
    if (profile != null) {
      if (mounted) {
        setState(() {
          _companyProfile = profile;
          if (_companyNameCtrl.text.isEmpty || _companyNameCtrl.text == 'Empresa') {
             _companyNameCtrl.text = profile.nombre;
          }
           _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _workerNameCtrl.dispose();
    _positionCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Comprobante de Pago',
      subtitle: 'Vista previa editable antes de exportar.',
      useScroll: true,
      body: Center(
        child: Column(
          children: [
            // Toolbar
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit, color: kNeonGold, size: 16),
                  const SizedBox(width: 8),
                  Text('Puedes editar los campos subrayados directamente en el documento.', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),

            // THE PAPER (Voucher)
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4), // Paper sharp corners
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo section (if exists)
                      if (_companyProfile?.logoBase64 != null && _companyProfile!.logoBase64!.isNotEmpty) ...[
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(_companyProfile!.logoBase64!),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Editable Company Name
                            _EditableField(
                              controller: _companyNameCtrl, 
                              style: GoogleFonts.oswald(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                              label: 'Nombre Empresa'
                            ),
                            Text('Comprobante de Salario', style: GoogleFonts.outfit(color: Colors.black54, fontSize: 14)),
                            if (_companyProfile?.ruc.isNotEmpty == true)
                              Text('RUC: ${_companyProfile!.ruc}', style: GoogleFonts.sourceCodePro(color: Colors.black45, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: GoogleFonts.sourceCodePro(color: Colors.black87, fontSize: 12)),
                          Text('Periodo: ${DateFormat('dd/MM').format(widget.input.periodStart)} - ${DateFormat('dd/MM').format(widget.input.periodEnd)}', style: GoogleFonts.sourceCodePro(color: Colors.black87, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black12, height: 32, thickness: 2),

                  // EMPLOYEE INFO
                  Row(
                    children: [
                      Expanded(child: _infoCol('Trabajador', _workerNameCtrl)),
                      Expanded(child: _infoCol('Cargo', _positionCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Non-editable stats
                      Expanded(child: _staticInfoCol('Salario Base', 'B/. ${widget.input.baseSalary.toStringAsFixed(2)}')),
                      Expanded(child: _staticInfoCol('Frecuencia', widget.input.frequency.name.toUpperCase())),
                    ],
                  ),
                  
                  const SizedBox(height: 32),

                  // CALCULATION TABLE
                  Text('DETALLE DE MOVIMIENTOS', style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  _buildDetailTable(),
                  
                  const SizedBox(height: 24),
                  // TOTALS bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('NETO A PAGAR', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18)),
                        Text('B/. ${widget.result.netSalary.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // NOTES
                  Text('Observaciones:', style: GoogleFonts.outfit(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                  _EditableField(
                    controller: _notesCtrl, 
                    style: GoogleFonts.sourceCodePro(color: Colors.black87, fontSize: 12),
                    label: 'Agregar notas...',
                    maxLines: 2,
                  ),
                  
                  const SizedBox(height: 32),
                  // Auto-generated footer
                  Center(child: Text('Documento generado digitalmente por Proyecto Empodérate', style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 10))),
                ],
              ),
            ),

            const SizedBox(height: 48),
            
            // ACTIONS
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _ActionButton(
                  icon: Icons.picture_as_pdf, 
                  label: 'Generar PDF', 
                  color: Colors.redAccent, 
                  onTap: () => _generateAndSharePdf(context, share: false)
                ),
                _ActionButton(
                  icon: Icons.share, 
                  label: 'Compartir', 
                  color: kNeonBlue, 
                  onTap: () => _generateAndSharePdf(context, share: true)
                ),
                _ActionButton(
                  icon: Icons.lock, 
                  label: 'Guardar en Bóveda', 
                  color: const Color(0xFFD4AF37), // Gold
                  onTap: () => _saveToVault(context)
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _infoCol(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.outfit(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.bold)),
        _EditableField(controller: ctrl, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600), label: label),
      ],
    );
  }

  Widget _staticInfoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.outfit(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDetailTable() {
    final result = widget.result;
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey[300]!, width: 0.5),
        bottom: const BorderSide(color: Colors.black12, width: 1),
      ),
      columnWidths: const {0: FlexColumnWidth(4), 1: FlexColumnWidth(2)},
      children: [
        // INGRESOS
        _tableSectionHeader('INGRESOS'),
        _tableRow('Salario Base', result.baseIncome),
        if (result.overtimeDaytimeAmount > 0) _tableRow('Horas Extras Diurnas', result.overtimeDaytimeAmount),
        if (result.overtimeNightAmount > 0) _tableRow('Horas Extras Nocturnas', result.overtimeNightAmount),
        if (result.overtimeMixedAmount > 0) _tableRow('Horas Extras Mixtas', result.overtimeMixedAmount),
        if (result.sundayAmount > 0) _tableRow('Domingos / Feriados', result.sundayAmount + result.holidayAmount), // Combined for cleaner look? No, keep separate if needed.
        if (result.nightSurchargeAmount > 0) _tableRow('Recargo Nocturno', result.nightSurchargeAmount),
        if (result.commissionsAmount > 0) _tableRow('Comisiones', result.commissionsAmount),
        if (result.bonusesAmount > 0) _tableRow('Bonificaciones', result.bonusesAmount),
        if (result.vacationPayment > 0) _tableRow('Pago de Vacaciones', result.vacationPayment),
        _tableRow('TOTAL INGRESOS', result.totalDevengado, isBold: true),

        // DEDUCCIONES
        _tableSectionHeader('DEDUCCIONES'),
        _tableRow('Seguro Social (9.75%)', result.css, isNegative: true),
        _tableRow('Seguro Educativo (1.25%)', result.se, isNegative: true),
        _tableRow('Impuesto Sobre la Renta', result.isr, isNegative: true),
        if (result.otherDeductions > 0) _tableRow('Otros Descuentos', result.otherDeductions, isNegative: true),
        _tableRow('TOTAL DEDUCCIONES', result.totalDeducciones, isBold: true, isNegative: true),
      ],
    );
  }

  TableRow _tableSectionHeader(String title) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(title, style: GoogleFonts.outfit(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(),
      ]
    );
  }

  TableRow _tableRow(String label, double amount, {bool isBold = false, bool isNegative = false}) {
    final styleLine = GoogleFonts.sourceCodePro(
      fontSize: 12,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: isNegative ? (isBold ? Colors.red[900] : Colors.red[700]) : (isBold ? Colors.black : Colors.black87)
    );
    
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(label, style: styleLine)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('${isNegative ? "-" : ""}${amount.toStringAsFixed(2)}', style: styleLine, textAlign: TextAlign.right)),
      ]
    );
  }

  Future<void> _generateAndSharePdf(BuildContext context, {required bool share}) async {
    final doc = pw.Document();
    
    // Capture current edited values
    final companyName = _companyNameCtrl.text;
    final workerName = _workerNameCtrl.text;
    final position = _positionCtrl.text;
    final notes = _notesCtrl.text;
    
    final result = widget.result; 

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(50),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo (if exists)
                  if (_companyProfile?.logoBase64 != null && _companyProfile!.logoBase64!.isNotEmpty) ...[
                    pw.Container(
                      width: 60,
                      height: 60,
                      margin: const pw.EdgeInsets.only(right: 12),
                      child: pw.Image(
                        pw.MemoryImage(base64Decode(_companyProfile!.logoBase64!)),
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ],
                   pw.Expanded(
                     child: pw.Column(
                       crossAxisAlignment: pw.CrossAxisAlignment.start,
                       children: [
                         pw.Text(companyName.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),
                         pw.Text('COMPROBANTE DE PAGO', style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                         if (_companyProfile?.ruc.isNotEmpty == true)
                            pw.Text('RUC: ${_companyProfile!.ruc}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                       ]
                     ),
                   ),
                   pw.Column(
                     crossAxisAlignment: pw.CrossAxisAlignment.end,
                     children: [
                       pw.Text('FECHA: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
                       pw.Text('PERIODO: ${DateFormat('dd/MM').format(widget.input.periodStart)} - ${DateFormat('dd/MM').format(widget.input.periodEnd)}', style: const pw.TextStyle(fontSize: 10)),
                     ]
                   )
                ]
              ),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 20),

              // Employee
              pw.Row(children: [
                pw.Expanded(child: _pdfKV('TRABAJADOR', workerName)),
                pw.Expanded(child: _pdfKV('CARGO', position)),
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Expanded(child: _pdfKV('SALARIO BASE', 'B/. ${widget.input.baseSalary.toStringAsFixed(2)}')),
                pw.Expanded(child: _pdfKV('FRECUENCIA', widget.input.frequency.name.toUpperCase())),
              ]),
              pw.SizedBox(height: 30),

              // Table
              pw.Table(
                columnWidths: {0: const pw.FlexColumnWidth(4), 1: const pw.FlexColumnWidth(1)},
                border: pw.TableBorder(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
                children: [
                  // Header
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.only(bottom: 5), child: pw.Text('CONCEPTO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.grey600))),
                    pw.Padding(padding: const pw.EdgeInsets.only(bottom: 5), child: pw.Text('MONTO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.grey600), textAlign: pw.TextAlign.right)),
                  ]),
                  
                  ..._pdfItems(result),
                  
                ]
              ),
              
              pw.SizedBox(height: 20),
               pw.Container(
                  color: PdfColors.grey100,
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('NETO A PAGAR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.Text('B/. ${result.netSalary.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    ]
                  )
               ),
               
               if (notes.isNotEmpty) ...[
                 pw.SizedBox(height: 20),
                 pw.Text('OBSERVACIONES:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                 pw.Text(notes, style: const pw.TextStyle(fontSize: 10)),
               ],
               
               pw.Spacer(),
               // Signatures
               pw.Row(
                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                 children: [
                   _pdfSignBox('Recibido Conforme (Trabajador)'),
                   _pdfSignBox('Autorizado Por (Empresa)'),
                 ]
               ),
               pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    if (share) {
      await Printing.sharePdf(bytes: await doc.save(), filename: 'comprobante_${workerName.replaceAll(' ', '_')}.pdf');
    } else {
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
    }
  }

  Future<void> _saveToVault(BuildContext context) async {
    try {
      final name = 'Comprobante_${_workerNameCtrl.text.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}';
      await BovedaService().saveDocument(
        title: name,
        category: DocCategory.rrhh,
        content: 'Comprobante de Pago: ${_workerNameCtrl.text}\nPeriodo: ${DateFormat('dd/MM').format(widget.input.periodStart)} - ${DateFormat('dd/MM').format(widget.input.periodEnd)}\nNeto: B/. ${widget.result.netSalary.toStringAsFixed(2)}',
        extension: '.pdf',
      );
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name guardado en Bóveda ✅'),
          backgroundColor: const Color(0xFF00C853),
        )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
  
  pw.Widget _pdfSignBox(String label) {
    return pw.Column(
      children: [
        pw.Container(width: 200, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 5),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
      ]
    );
  }
  
  pw.Widget _pdfKV(String k, String v) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(k, style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
      pw.Text(v, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
    ]);
  }
  
  List<pw.TableRow> _pdfItems(SalarioResultModel r) {
    final items = <pw.TableRow>[];
    
    void add(String label, double val, {bool isNeg = false, bool bold = false}) {
      items.add(pw.TableRow(children: [
        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 3), child: pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : null))),
        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 3), child: pw.Text('${isNeg?"-":""}${val.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : null, color: isNeg ? PdfColors.red900 : PdfColors.black), textAlign: pw.TextAlign.right)),
      ]));
    }
    
    add('Salario Base', r.baseIncome);
    if (r.overtimeDaytimeAmount > 0) add('Extras Diurnas', r.overtimeDaytimeAmount);
    if (r.overtimeNightAmount > 0) add('Extras Nocturnas', r.overtimeNightAmount);
    if (r.overtimeMixedAmount > 0) add('Extras Mixtas', r.overtimeMixedAmount);
    if (r.sundayAmount > 0) add('Domingos', r.sundayAmount);
    if (r.holidayAmount > 0) add('Feriados', r.holidayAmount);
    if (r.nightSurchargeAmount > 0) add('Recargo Nocturno', r.nightSurchargeAmount);
    if (r.vacationPayment > 0) add('Pago de Vacaciones', r.vacationPayment);
    if (r.totalDevengado != r.baseIncome) add('TOTAL INGRESOS', r.totalDevengado, bold: true);
    
    add('Seguro Social', r.css, isNeg: true);
    add('Seguro Educativo', r.se, isNeg: true);
    add('ISR', r.isr, isNeg: true);
    if (r.otherDeductions > 0) add('Otros Descuentos', r.otherDeductions, isNeg: true);
    add('TOTAL DEDUCCIONES', r.totalDeducciones, isNeg: true, bold: true);
    
    return items;
  }
}

class _EditableField extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle style;
  final String label;
  final int maxLines;

  const _EditableField({required this.controller, required this.style, required this.label, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: style,
      maxLines: maxLines,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        border: const UnderlineInputBorder(borderSide: BorderSide.none), // Invisible by default
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12, style: BorderStyle.solid)), // Subtle line to show editability
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kNeonGold, width: 2)),
        hintText: label,
        hintStyle: style.copyWith(color: Colors.black26),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: color.withOpacity(0.4),
      ),
    );
  }
}
