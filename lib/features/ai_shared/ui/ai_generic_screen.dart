import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/business_profile/business_profile_models.dart';
import 'package:proyecto_empoderate/src/business_profile/reminder_service_placeholder.dart';
import '../domain/ai_shared_types.dart';
import '../domain/ai_generic_request.dart';
import '../domain/ai_generic_output.dart';
import '../data/ai_generic_service.dart';

import '../data/ai_generic_context_service.dart';
import '../data/ai_document_generator.dart';

class AiGenericScreen extends StatefulWidget {
  final AiFeatureType featureType;

  const AiGenericScreen({
    Key? key,
    required this.featureType,
  }) : super(key: key);

  @override
  State<AiGenericScreen> createState() => _AiGenericScreenState();
}

class _AiGenericScreenState extends State<AiGenericScreen> {
  final AiGenericService _service = AiGenericService();
  final AiGenericContextService _contextService = AiGenericContextService();
  final TextEditingController _promptController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSaving = false;
  AiGenericOutput? _currentOutput;
  bool _showFormFields = false; // Toggle for advanced form
  
  // Form controllers for dynamic fields
  final Map<String, TextEditingController> _formControllers = {};

  Future<void> _generate() async {
    if (_promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escribe tu idea primero.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Get Context
      final contextString = await _contextService.buildContextString(widget.featureType);

      // 2. Collect form data
      final formData = <String, String>{};
      _formControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          formData[key] = controller.text;
        }
      });

      // 3. Create Request with Context and Form Data
      final request = AiGenericRequest(
        type: widget.featureType,
        prompt: _promptController.text,
        context: contextString,
        formData: formData.isNotEmpty ? formData : null,
      );
      
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
        const SnackBar(content: Text('Error al generar. Intenta de nuevo.')),
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
          content: Text('¡Guardado con éxito!'),
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

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copiado al portapapeles'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _addToAgenda(AiAction action) async {
    final reminder = BusinessReminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: action.taskTitle,
      descripcion: action.taskDescription,
      fecha: DateTime.now().add(const Duration(days: 1)), // Default tomorrow
    );

    await ReminderServicePlaceholder().addReminder(reminder);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📅 Agendado: ${action.taskTitle}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _downloadPdf() async {
    if (_currentOutput == null) return;
    try {
      await AiDocumentGenerator().generateAndDownload(_currentOutput!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📄 PDF Generado con éxito app')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generando PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.featureType;

    return PremiumScaffold(
      title: type.label,
      subtitle: type.subtitle,
      body: Column(
        children: [
          // INSTRUCTIONS CARD
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F).withOpacity(0.3),
              border: Border.all(color: EmpoderateTheme.gold.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: EmpoderateTheme.gold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '¿CÓMO USAR ESTA HERRAMIENTA?',
                      style: GoogleFonts.outfit(
                        color: EmpoderateTheme.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  type.instructions,
                  style: GoogleFonts.roboto(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // PROMPT CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: EmpoderateTheme.premiumGlassCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TU IDEA O NECESIDAD',
                  style: GoogleFonts.outfit(color: EmpoderateTheme.gold, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _promptController,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                  maxLines: 4,
                  decoration: EmpoderateTheme.inputDecoration(type.promptHint),
                  onFieldSubmitted: (_) => _generate(), // Enter key triggers generation
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                
                // TOGGLE BUTTON FOR FORM FIELDS
                OutlinedButton.icon(
                  onPressed: () => setState(() => _showFormFields = !_showFormFields),
                  icon: Icon(_showFormFields ? Icons.expand_less : Icons.expand_more),
                  label: Text(_showFormFields ? 'OCULTAR DATOS OPCIONALES' : 'COMPLETAR DATOS PARA DOCUMENTO FINAL'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EmpoderateTheme.gold,
                    side: BorderSide(color: EmpoderateTheme.gold.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                
                // DYNAMIC FORM FIELDS
                if (_showFormFields) ...[
                  const SizedBox(height: 20),
                  ..._buildDynamicFormFields(),
                ],
                
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: EmpoderateTheme.gold))
                    : ElevatedButton.icon(
                        onPressed: _generate,
                        icon: const Icon(Icons.auto_awesome),
                        label: Text('GENERAR ${type.label.replaceAll('IA PARA ', '')}'),
                        style: EmpoderateTheme.primaryButtonStyle,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // RESULTS
          if (_currentOutput != null) ...[
            _buildResultCard('RESULTADO PRINCIPAL', _currentOutput!.content, Icons.description),
            const SizedBox(height: 16),
            
            // SMART ACTIONS
            if (_currentOutput!.suggestedActions.isNotEmpty) ...[
               Column(
                children: _currentOutput!.suggestedActions.map((action) => 
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _addToAgenda(action),
                      icon: const Icon(Icons.calendar_month, color: Colors.white),
                      label: Text('AGREGAR A AGENDA: ${action.label.toUpperCase()}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent, 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        elevation: 4,
                      ),
                    ),
                  )
                ).toList(),
              ),
            ],

            // PDF DOWNLOAD BUTTON
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _downloadPdf,
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                  label: const Text('DESCARGAR DOCUMENTO PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),

            _buildResultCard('INFORMACIÓN EXTRA', _currentOutput!.extraInfo, Icons.lightbulb),
            const SizedBox(height: 16),
            _buildResultCard('PLAN DE ACCIÓN', _currentOutput!.actionPlan, Icons.rocket_launch),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _generate,
                    icon: const Icon(Icons.refresh),
                    label: const Text('REGENERAR'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.bookmark_border),
                    label: Text(_isSaving ? 'GUARDANDO...' : 'GUARDAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: Colors.white54),
                onPressed: () => _copy(content),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicFormFields() {
    final type = widget.featureType;
    
    // Helper to build a text field
    Widget buildField(String key, String label, {String hint = '', int maxLines = 1}) {
      // Initialize controller if not exists
      if (!_formControllers.containsKey(key)) {
        _formControllers[key] = TextEditingController();
      }
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _formControllers[key],
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: EmpoderateTheme.gold, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Different fields based on type
    switch (type) {
      case AiFeatureType.products:
        return [
          Text(
            'DATOS DEL PRODUCTO/SERVICIO',
            style: GoogleFonts.outfit(color: EmpoderateTheme.gold, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          buildField('price', 'Precio (B/.)', hint: 'Ej: 150.00'),
          buildField('material', 'Material/Composición', hint: 'Ej: Algodón 100%, Acero inoxidable'),
          buildField('dimensions', 'Dimensiones/Tamaño', hint: 'Ej: 30cm x 20cm x 10cm'),
          buildField('warranty', 'Garantía (meses/años)', hint: 'Ej: 12 meses'),
          buildField('deliveryTime', 'Tiempo de Entrega', hint: 'Ej: Inmediata, 2-5 días'),
          buildField('phone', 'WhatsApp/Teléfono', hint: 'Ej: +507 6789-1234'),
          buildField('email', 'Email de Contacto', hint: 'Ej: ventas@empresa.com'),
          buildField('address', 'Dirección Física', hint: 'Ej: Vía Brasil, Ciudad de Panamá'),
        ];

      case AiFeatureType.contracts:
        return [
          Text(
            'DATOS DEL CONTRATO',
            style: GoogleFonts.outfit(color: EmpoderateTheme.gold, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          buildField('party1Name', 'Nombre Completo Parte 1', hint: 'Ej: Juan Pérez o Empresa SA'),
          buildField('party1Id', 'Cédula/RUC Parte 1', hint: 'Ej: 8-123-4567 o 123456-1-12345'),
          buildField('party1Address', 'Dirección Parte 1', hint: 'Ej: Calle 50, Ciudad de Panamá'),
          buildField('party2Name', 'Nombre Completo Parte 2', hint: 'Ej: María García'),
          buildField('party2Id', 'Cédula/RUC Parte 2', hint: 'Ej: 8-765-4321'),
          buildField('party2Address', 'Dirección Parte 2', hint: 'Ej: Avenida Balboa, Panamá'),
          buildField('amount', 'Monto (B/.)', hint: 'Ej: 1,500.00'),
          buildField('startDate', 'Fecha de Inicio', hint: 'Ej: 1 de enero de 2025'),
          buildField('endDate', 'Fecha de Fin (opcional)', hint: 'Ej: 31 de diciembre de 2025'),
          buildField('propertyAddress', 'Dirección del Inmueble (Arrendamiento)', hint: 'Ej: Apartamento 5B, Edificio Torre Mar'),
          buildField('position', 'Cargo/Puesto (Laboral)', hint: 'Ej: Cajero, Vendedor'),
          buildField('services', 'Servicios a Prestar (Servicios)', hint: 'Ej: Diseño de logo y branding', maxLines: 2),
        ];

      case AiFeatureType.processes:
        return [
          Text(
            'DATOS DEL PROCEDIMIENTO',
            style: GoogleFonts.outfit(color: EmpoderateTheme.gold, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          buildField('responsibleName', 'Nombre del Responsable', hint: 'Ej: Carlos Mendoza'),
          buildField('responsibleTitle', 'Cargo del Responsable', hint: 'Ej: Supervisor de Ventas'),
          buildField('approverName', 'Quien Aprueba el SOP', hint: 'Ej: Gerente General'),
          buildField('department', 'Departamento/Área', hint: 'Ej: Ventas, Operaciones, Atención al Cliente'),
          buildField('targetPersonnel', 'Personal Involucrado', hint: 'Ej: Cajeros, Vendedores, Meseros'),
          buildField('estimatedTime', 'Tiempo Estimado (minutos)', hint: 'Ej: 15-20 minutos'),
        ];

      case AiFeatureType.strategies:
        return [
          Text(
            'DATOS DE LA ESTRATEGIA',
            style: GoogleFonts.outfit(color: EmpoderateTheme.gold, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          buildField('budget', 'Presupuesto Total (B/.)', hint: 'Ej: 5,000'),
          buildField('marketingBudget', 'Presupuesto Marketing (B/.)', hint: 'Ej: 2,000'),
          buildField('techBudget', 'Presupuesto Tecnología (B/.)', hint: 'Ej: 1,500'),
          buildField('responsibleName', 'Responsable del Proyecto', hint: 'Ej: Ana López'),
          buildField('responsibleTitle', 'Cargo del Responsable', hint: 'Ej: Director Comercial'),
          buildField('targetCustomers', 'Meta de Clientes Nuevos', hint: 'Ej: 100 clientes'),
          buildField('salesIncrease', 'Incremento de Ventas Deseado (%)', hint: 'Ej: 30'),
        ];
    }
  }
}
