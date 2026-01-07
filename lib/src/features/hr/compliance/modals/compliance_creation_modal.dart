import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/neon_widgets.dart';
import '../hr_compliance_service.dart';
import '../hr_compliance_models.dart';

class ComplianceCreationModal extends StatefulWidget {
  final bool initialAiMode;
  final VoidCallback onSuccess;

  const ComplianceCreationModal({
    Key? key,
    this.initialAiMode = false,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<ComplianceCreationModal> createState() => _ComplianceCreationModalState();
}

class _ComplianceCreationModalState extends State<ComplianceCreationModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = HrComplianceService();
  bool _isLoading = false;

  // Manual Form
  final _titleCtrl = TextEditingController();
  String _category = 'general';
  String _frequency = 'monthly';
  String _priority = 'media';
  final _dueRuleCtrl = TextEditingController(text: 'Fin de mes');

  // AI Form
  final _aiContextCtrl = TextEditingController();
  List<Map<String, dynamic>> _aiSuggestions = [];
  Set<int> _selectedSuggestions = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialAiMode ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF0F1525),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Nueva Obligación',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.cyanAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: "Manual"),
                Tab(text: "Asistente IA"),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildManualTab(),
                _buildAiTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        NeonInput(label: "Título de la Obligación", controller: _titleCtrl, hint: "Ej. Pago de Impuestos"),
        
        NeonDropdown<String>(
          label: "Categoría",
          value: _category,
          items: const [
             DropdownMenuItem(value: 'general', child: Text('General')),
             DropdownMenuItem(value: 'impuestos', child: Text('Impuestos')),
             DropdownMenuItem(value: 'planilla', child: Text('Planilla')),
             DropdownMenuItem(value: 'seguridad_social', child: Text('Seguridad Social')),
             DropdownMenuItem(value: 'permisos', child: Text('Permisos')),
          ],
          onChanged: (v) => setState(() => _category = v!),
        ),

        Row(
          children: [
            Expanded(
              child: NeonDropdown<String>(
                label: "Frecuencia",
                value: _frequency,
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
                  DropdownMenuItem(value: 'annual', child: Text('Anual')),
                  DropdownMenuItem(value: 'event', child: Text('Eventual')),
                ],
                onChanged: (v) => setState(() => _frequency = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NeonDropdown<String>(
                label: "Prioridad",
                value: _priority,
                items: const [
                  DropdownMenuItem(value: 'alta', child: Text('Alta')),
                  DropdownMenuItem(value: 'media', child: Text('Media')),
                  DropdownMenuItem(value: 'baja', child: Text('Baja')),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
            ),
          ],
        ),

        NeonInput(label: "Regla de Vencimiento", controller: _dueRuleCtrl, hint: "Ej. Día 15, Fin de mes"),
        
        const SizedBox(height: 20),
        
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
        else
          NeonButton(
            text: "Crear y Guardar",
            icon: Icons.save,
            onTap: _createManual,
          )
      ],
    );
  }

  Future<void> _createManual() async {
    if (_titleCtrl.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    final item = HrObligationCatalog(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID, service generates real one if needed or uses this
      title: _titleCtrl.text,
      category: _category,
      frequency: _frequency,
      priority: _priority,
      dueRule: _dueRuleCtrl.text,
      responsible: 'Usuario',
      active: true,
    );

    final now = DateTime.now();
    await _service.createManualObligation(
      item, 
      true, // Create for current month
      now.year, 
      now.month, 
      saveToCatalog: true
    );

    if (mounted) {
      setState(() => _isLoading = false);
      widget.onSuccess();
      Navigator.pop(context);
    }
  }

  Widget _buildAiTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_aiSuggestions.isEmpty) ...[
           Text(
             'Describe tu negocio para que la IA sugiera tus obligaciones laborales y fiscales.',
             style: GoogleFonts.outfit(color: Colors.white70),
           ),
           const SizedBox(height: 16),
           NeonInput(
             label: "Contexto del Negocio", 
             controller: _aiContextCtrl, 
             maxLines: 4,
             hint: "Ej. Soy un restaurante pequeño con 5 empleados en Ciudad de Panamá...",
           ),
           const SizedBox(height: 20),
           if (_isLoading)
             const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
           else
             NeonButton(
               text: "Analizar y Sugerir",
               icon: Icons.auto_awesome,
               onTap: _runAiAnalysis,
             )
        ] else ...[
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text('Sugerencias Encontradas', style: GoogleFonts.outfit(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
               TextButton(
                 onPressed: () => setState(() { _aiSuggestions.clear(); _selectedSuggestions.clear(); }),
                 child: const Text('Reiniciar', style: TextStyle(color: Colors.white54)),
               )
             ],
           ),
           const SizedBox(height: 10),
           ...List.generate(_aiSuggestions.length, (index) {
              final item = _aiSuggestions[index];
              final isSelected = _selectedSuggestions.contains(index);
              return GestureDetector(
                onTap: () => setState(() {
                   if (isSelected) _selectedSuggestions.remove(index);
                   else _selectedSuggestions.add(index);
                }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.cyanAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                    border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.white10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                        color: isSelected ? Colors.cyanAccent : Colors.white24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('${item['frequency']} • ${item['priority']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            Text('Razón: ${item['reason']}', style: const TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
           }),
           const SizedBox(height: 20),
           if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
           else
              NeonButton(
                text: "Aplicar Seleccionados (${_selectedSuggestions.length})",
                onTap: _applyAiSelection,
                primary: _selectedSuggestions.isNotEmpty,
              )
        ]
      ],
    );
  }

  Future<void> _runAiAnalysis() async {
    if (_aiContextCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    
    final contextMap = {
      'text': _aiContextCtrl.text,
      'has_employees': _aiContextCtrl.text.toLowerCase().contains('empleado') || _aiContextCtrl.text.toLowerCase().contains('personal'),
      'type': _aiContextCtrl.text.split(' ').take(3).join(' '), // Mock extraction
    };
    
    final results = await _service.simulateAiSuggestions(contextMap, DateTime.now().month);
    
    if (mounted) {
      setState(() {
        _aiSuggestions = results;
        _isLoading = false;
        // Auto select all
        _selectedSuggestions = List.generate(results.length, (i) => i).toSet();
      });
    }
  }

  Future<void> _applyAiSelection() async {
    if (_selectedSuggestions.isEmpty) return;
    setState(() => _isLoading = true);

    final selectedItems = _selectedSuggestions.map((i) => _aiSuggestions[i]).toList();
    
    final now = DateTime.now();
    await _service.applyAiSuggestions(selectedItems, now.year, now.month);

    if (mounted) {
      setState(() => _isLoading = false);
      widget.onSuccess();
      Navigator.pop(context);
    }
  }
}
