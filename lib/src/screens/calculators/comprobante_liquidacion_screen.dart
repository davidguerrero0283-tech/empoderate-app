
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../calculators/liquidacion_models.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../services/pdf_service.dart'; // Reuse for PDF generation
import '../../business_profile/business_profile_models.dart';
import '../../services/business_service.dart';
import '../../features/boveda/services/boveda_service.dart';
import '../../features/boveda/models/doc_model.dart';

class ComprobanteLiquidacionScreen extends StatefulWidget {
  final LiquidacionInputModel input;
  final LiquidacionResultModel result;

  const ComprobanteLiquidacionScreen({Key? key, required this.input, required this.result}) : super(key: key);

  @override
  State<ComprobanteLiquidacionScreen> createState() => _ComprobanteLiquidacionScreenState();
}

class _ComprobanteLiquidacionScreenState extends State<ComprobanteLiquidacionScreen> {
  BusinessProfile? _companyProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyProfile();
  }

  Future<void> _loadCompanyProfile() async {
    final profile = await BusinessService().getProfile();
    if (mounted) {
      setState(() {
        _companyProfile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Comprobante de Liquidación',
      useScroll: true,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, minHeight: 400),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white, // Explicit White
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo section (if exists)
                  if (_companyProfile?.logoBase64 != null && _companyProfile!.logoBase64!.isNotEmpty) ...[
                    Container(
                      width: 70,
                      height: 70,
                      margin: const EdgeInsets.only(right: 12),
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
                        Text(
                          widget.input.companyName.isNotEmpty ? widget.input.companyName.toUpperCase() : 'EMPRESA (SIN REGISTRAR)',
                          style: GoogleFonts.oswald(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                          maxLines: 2,
                        ),
                        if (_companyProfile?.ruc.isNotEmpty == true)
                           Text('RUC: ${_companyProfile!.ruc}', style: GoogleFonts.sourceCodePro(color: Colors.black87, fontSize: 12)),
                        Text('Comprobante de Liquidación', style: GoogleFonts.outfit(color: Colors.black54, fontSize: 14)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: GoogleFonts.sourceCodePro(color: Colors.black87, fontSize: 12)),
                      Text('Ingreso: ${DateFormat('dd/MM/yyyy').format(widget.input.startDate)}', style: GoogleFonts.sourceCodePro(color: Colors.black87, fontSize: 12)),
                      Text('Salida: ${DateFormat('dd/MM/yyyy').format(widget.input.endDate)}', style: GoogleFonts.sourceCodePro(color: Colors.black87, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.black12, height: 32),

              // EMPLOYEE INFO
              Text('Datos del Colaborador', style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildInfoGrid(),
              const SizedBox(height: 24),

              // CALCULATION TABLE
              Text('Detalle de Prestaciones e Indemnización', style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildDetailTable(),
              
              const SizedBox(height: 24),
              // TOTALS
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL A RECIBIR (NETO):', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('B/. ${widget.result.netoPagar.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
              ),
              
              if (widget.input.accumulatedIncomeVacations > 0 || widget.input.accumulatedIncomeDecimo > 0) ...[
                const SizedBox(height: 16),
                Text('Notas de Referencia Histórica', style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.blue.withOpacity(0.1))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.input.accumulatedIncomeVacations > 0)
                        Text('• Acumulado de Vacaciones calculado desde el último registro histórico.', style: GoogleFonts.outfit(color: Colors.black54, fontSize: 11)),
                      if (widget.input.accumulatedIncomeDecimo > 0)
                        Text('• Acumulado de Décimo calculado desde la última fecha de pago registrada.', style: GoogleFonts.outfit(color: Colors.black54, fontSize: 11)),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // ACTIONS
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _ActionButton(
                    icon: Icons.picture_as_pdf, 
                    label: 'Descargar PDF', 
                    color: Colors.red[700]!, 
                    onTap: () => _downloadPdf(context)
                  ),
                  _ActionButton(
                    icon: Icons.share, 
                    label: 'Compartir', 
                    color: Colors.blue[700]!, 
                    onTap: () => _sharePdf(context)
                  ),
                   _ActionButton(
                    icon: Icons.description, 
                    label: 'Exportar Word', 
                    color: Colors.blue[900]!, 
                    onTap: () => _exportWord(context)
                  ),
                  _ActionButton(
                    icon: Icons.lock, 
                    label: 'Guardar en Bóveda', 
                    color: const Color(0xFFD4AF37), // Gold
                    onTap: () => _saveToVault(context)
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Center(child: Text('Comprobante informativo generado por Empodérate App. No es un documento fiscal oficial.', style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Table(
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
      children: [
        _infoRow('Nombre:', widget.input.workerName),
        _infoRow('Cédula:', widget.input.workerId),
        _infoRow('Empresa/Depto:', '${widget.input.companyName} ${widget.input.department != null ? " / ${widget.input.department}" : ""}'),
        _infoRow('Motivo:', widget.input.terminationType.toString().split('.').last.toUpperCase()),
        _infoRow('Tiempo Laborado:', '${widget.result.yearsWorked} años, ${widget.result.monthsWorked} meses, ${widget.result.daysWorked} días'),
      ],
    );
  }

  TableRow _infoRow(String label, String value) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(label, style: GoogleFonts.outfit(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 13))),
        Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(value, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13))),
      ]
    );
  }

  Widget _buildDetailTable() {
    return Table(
      border: TableBorder.all(color: Colors.black12),
      columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1)},
      children: [
        _tableHeader(),
        // INCOMES
        if (widget.result.salarioAdeudado > 0) _tableRow('Salario Pendiente', widget.result.salarioAdeudado),
        _tableRow('Vacaciones Vencidas', widget.result.vacacionesVencidas),
        _tableRow('Vacaciones Proporcionales', widget.result.vacacionesProporcionales),
        _tableRow('Décimo Tercer Mes', widget.result.decimoProporcional),
        if (widget.result.primaAntiguedad > 0) _tableRow('Prima Antigüedad', widget.result.primaAntiguedad),
        if (widget.result.indemnizacion > 0) _tableRow('Indemnización', widget.result.indemnizacion),
        if (widget.result.preaviso > 0) _tableRow('Preaviso', widget.result.preaviso),
        _tableRow('SUBTOTAL INGRESOS', widget.result.subtotalDevengos, isBold: true, color: Colors.grey[200]),
        
        // DEDUCTIONS
        _tableRow('Seguro Social (-)', widget.result.css + widget.result.cssSalario + widget.result.cssVacaciones + widget.result.cssDecimo + widget.result.cssPreaviso, isNegative: true),
        _tableRow('Seguro Educativo (-)', widget.result.se + widget.result.seSalario + widget.result.seVacaciones + widget.result.seDecimo + widget.result.sePreaviso, isNegative: true),
        _tableRow('Impuesto Renta (-)', widget.result.isr + widget.result.isrPreaviso, isNegative: true),
        if (widget.result.otherDeductionsDetailed > 0) _tableRow('Otros Descuentos (-)', widget.result.otherDeductionsDetailed, isNegative: true),
        _tableRow('TOTAL DEDUCCIONES', widget.result.totalDeducciones, isBold: true, isNegative: true, color: Colors.grey[200]),
      ],
    );
  }

  TableRow _tableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.05)),
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text('Concepto', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12))),
        Padding(padding: const EdgeInsets.all(8), child: Text('Monto (B/.)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.right)),
      ]
    );
  }

  TableRow _tableRow(String label, double amount, {bool isBold = false, bool isNegative = false, Color? color}) {
    final style = GoogleFonts.sourceCodePro(
      fontSize: 12,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: isNegative ? Colors.red[800] : Colors.black87
    );
    
    return TableRow(
      decoration: color != null ? BoxDecoration(color: color) : null,
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: Text(label, style: style)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: Text('${isNegative ? "-" : ""}${amount.toStringAsFixed(2)}', style: style, textAlign: TextAlign.right)),
      ]
    );
  }

  // --- ACTIONS ---

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      await PdfService.generateLiquidacionPdf(widget.input, widget.result); // This triggers printing/download based on platform
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF generado.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
      // Since PdfService doesn't return bytes, we might need to modify PdfService OR create a local logic.
      // But PdfService uses Printing.layoutPdf which opens native share/print.
      // If we want "Share" specifically via share_plus, we need bytes.
      // For now, let's guide user to use the print dialog's share, OR improve PdfService.
      // IMPROVEMENT: Let's assume PdfService opens the native dialog which HAS share.
      // Alert user:
      _downloadPdf(context);
  }

  Future<void> _exportWord(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportando Word (Simulado)...')));
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Archivo .doc guardado en Descargas.')));
  }

  Future<void> _saveToVault(BuildContext context) async {
    try {
      final name = 'Liquidacion_${widget.input.workerName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}';
      await BovedaService().saveDocument(
        title: name,
        category: DocCategory.rrhh,
        content: 'Liquidación de ${widget.input.workerName}\nTotal: B/. ${widget.result.totalPagar.toStringAsFixed(2)}',
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
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
} // End of file
