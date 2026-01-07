import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:proyecto_empoderate/src/widgets/feature_intro_screen.dart';

import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../calculators/fixed_costs/fixed_costs_models.dart';
import '../../calculators/fixed_costs/fixed_costs_logic.dart';
import '../../calculators/fixed_costs/fixed_costs_export_service.dart';
import '../../components/calculator_info_panel.dart';
import '../../../ui/theme/empoderate_theme.dart';

class FixedCostsScreen extends StatefulWidget {
  const FixedCostsScreen({Key? key}) : super(key: key);

  @override
  _FixedCostsScreenState createState() => _FixedCostsScreenState();
}

class _FixedCostsScreenState extends State<FixedCostsScreen> with SingleTickerProviderStateMixin {
  bool _showIntro = true;
  FixedCostsScenario? _currentScenario;
  bool _isLoading = true;
  late TabController _tabController;

  // Break-even inputs
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _variableCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final scenarios = await FixedCostsLogic.loadScenarios();
    if (scenarios.isNotEmpty) {
      setState(() {
        _currentScenario = scenarios.first; // Load first for now
        _isLoading = false;
      });
    } else {
      // Create default
      final newScenario = FixedCostsLogic.createNewScenario('Mi Escenario Base');
      await FixedCostsLogic.saveScenario(newScenario);
      setState(() {
        _currentScenario = newScenario;
        _isLoading = false;
      });
    }
  }

  void _saveChanges() {
    if (_currentScenario != null) {
      _currentScenario!.lastUpdated = DateTime.now();
      FixedCostsLogic.saveScenario(_currentScenario!);
      setState(() {}); // Refresh UI
    }
  }

  void _duplicateScenario() {
    if (_currentScenario == null) return;
    
    showDialog(
      context: context,
      builder: (ctx) {
        String newName = '${_currentScenario!.name} (Copia)';
        return AlertDialog(
          backgroundColor: const Color(0xFF151C2B),
          title: Text('Guardar copia como...', style: GoogleFonts.outfit(color: Colors.white)),
          content: TextField(
            style: GoogleFonts.outfit(color: Colors.white),
            controller: TextEditingController(text: newName),
            onChanged: (v) => newName = v,
            decoration: const InputDecoration(labelText: 'Nombre del Escenario'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(ctx),
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                final copy = FixedCostsScenario(
                  id: const Uuid().v4(),
                  name: newName,
                  items: List.from(_currentScenario!.items), // Deep copy items if needed, but Item is immutable-ish for now
                  lastUpdated: DateTime.now(),
                );
                await FixedCostsLogic.saveScenario(copy);
                setState(() => _currentScenario = copy);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escenario copiado y guardado.')));
              },
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const PremiumScaffold(
        title: 'COSTOS FIJOS',
        body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
      );
    }

    final double totalMonthly = _currentScenario?.totalMonthly ?? 0;
    final double totalAnnual = _currentScenario?.totalAnnual ?? 0;
    final double dailyEq = _currentScenario?.dailyEquivalent ?? 0;

    return PremiumScaffold(
      title: 'COSTOS FIJOS (OVERHEAD)',
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF151C2B),
          onSelected: (val) async {
            if (_currentScenario == null) return;
            switch(val) {
              case 'save': 
                 _saveChanges();
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado.')));
                 break;
              case 'save_as': _duplicateScenario(); break;
              case 'pdf': await FixedCostsExportService.exportPdf(_currentScenario!); break;
              case 'word': await FixedCostsExportService.exportDocx(_currentScenario!); break;
              case 'share': await FixedCostsExportService.shareSummary(_currentScenario!); break;
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'save', child: Text('Guardar', style: TextStyle(color: Colors.white))),
            const PopupMenuItem(value: 'save_as', child: Text('Guardar como...', style: TextStyle(color: Colors.white))),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'pdf', child: Text('Exportar PDF', style: TextStyle(color: Colors.white))),
            const PopupMenuItem(value: 'word', child: Text('Exportar Word', style: TextStyle(color: Colors.white))),
            const PopupMenuItem(value: 'share', child: Text('Compartir Resumen', style: TextStyle(color: Colors.white))),
          ],
        )
      ],
      useScroll: false,
      usePadding: false,
      body: Stack(
        children: [
          // MAIN CONTENT - wrapped in Positioned.fill
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER & KPI
                  _buildKpiSection(totalMonthly, totalAnnual, dailyEq),
                  
                  const SizedBox(height: 16),
                  const CalculatorInfoPanel(configId: 'fixed_costs'),
                  const SizedBox(height: 16),
                  
                  // 2. QUICK ADD CHIPS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickChip('Alquiler', 'Infraestructura', CostFrequency.mensual),
                        _buildQuickChip('Internet', 'Servicios', CostFrequency.mensual),
                        _buildQuickChip('Seguro', 'Legal', CostFrequency.anual),
                        _buildQuickChip('Suscripciones', 'Software', CostFrequency.mensual),
                        _buildQuickChip('Licencias', 'Legal', CostFrequency.anual),
                        _buildQuickChip('Préstamo', 'Financiero', CostFrequency.mensual),
                        _buildQuickChip('Nómina Admin', 'RRHH', CostFrequency.mensual),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
    
                  // 3. TABLE
                  NeonCard(
                    borderColor: Colors.teal,
                    child: Column(
                      children: [
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text('Detalle de Costos', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                               ElevatedButton.icon(
                                 onPressed: () => _showEditModal(),
                                 icon: const Icon(Icons.add, size: 16),
                                 label: const Text('AGREGAR'),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: const Color(0xFFD4AF37).withOpacity(0.2),
                                   foregroundColor: const Color(0xFFD4AF37),
                                   elevation: 0,
                                 ),
                               )
                             ],
                           ),
                         ),
                         const Divider(color: Colors.white12, height: 1),
                         _buildCostTable(),
                      ],
                    ),
                  ),
    
                  const SizedBox(height: 32),
    
                  // 4. TABS
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFFD4AF37),
                    labelColor: const Color(0xFFD4AF37),
                    unselectedLabelColor: Colors.white60,
                    tabs: const [
                      Tab(text: 'RESUMEN'),
                      Tab(text: 'PUNTO DE EQUILIBRIO'),
                    ],
                  ),
                  
                  SizedBox(
                    height: 450,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSummaryTab(),
                        _buildBreakEvenTab(totalMonthly),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),

          // --- INTRO OVERLAY ---
          if (_showIntro)
            Positioned.fill(
              child: FeatureIntroScreen(
                key: const ValueKey('IntroOverlay'),
                title: 'COSTOS FIJOS (OH)',
                subTitle: 'Conoce el costo real de mantener tu negocio abierto. Domina tu "Burn Rate".',
                heroEmoji: '🏢',
                primaryColor: const Color(0xFF64B5F6), // Blue
                features: const [
                  IntroFeatureItem(Icons.business_center, 'Overhead'),
                  IntroFeatureItem(Icons.timer, 'Burn Rate'),
                  IntroFeatureItem(Icons.analytics, 'Optimización'),
                ],
                processSteps: const [
                  IntroStepItem('1. Categoriza', 'Infraestructura, RRHH, etc.'),
                  IntroStepItem('2. Frecuencia', 'Mensual, anual o único.'),
                  IntroStepItem('3. Escenario', 'Crea diferentes versiones.'),
                ],
                proTip: 'Los costos fijos no dependen de las ventas. ¡Son los más peligrosos!',
                onDismiss: () => setState(() => _showIntro = false),
              ),
            ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildKpiSection(double month, double year, double day) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildKpiCard('Total Mensual', month, Colors.tealAccent)),
            const SizedBox(width: 12),
            Expanded(child: _buildKpiCard('Total Anual', year, Colors.amberAccent)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
             Expanded(child: _buildKpiCard('Costo Fijo Diario', day, Colors.white70, isSmall: true)),
          ],
        )
      ],
    );
  }

  Widget _buildKpiCard(String label, double amount, Color color, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: isSmall ? 12 : 13)),
          const SizedBox(height: 4),
          Text(
            '\$${NumberFormat("#,##0.00", "en_US").format(amount)}',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: isSmall ? 18 : 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, String cat, CostFrequency f) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        backgroundColor: Colors.white.withOpacity(0.1),
        labelStyle: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
        onPressed: () {
          _showEditModal(initialName: label, initialCat: cat, initialFreq: f);
        },
      ),
    );
  }

  Widget _buildCostTable() {
    if (_currentScenario == null || _currentScenario!.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text('No hay costos registrados.', style: GoogleFonts.outfit(color: Colors.white30))),
      );
    }
    
    // Simple List View acting as Table for responsiveness
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _currentScenario!.items.length,
      itemBuilder: (ctx, i) {
        final item = _currentScenario!.items[i];
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            title: Text(item.name, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
            subtitle: Text('${item.category} • ${item.frequency.label}', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${item.amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.tealAccent, fontSize: 14)),
                    Text('Men eq: \$${item.monthlyEquivalent.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 10),
                IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.white30), onPressed: () => _showEditModal(item: item)),
                IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent), onPressed: () {
                    setState(() {
                      _currentScenario!.items.removeAt(i);
                    });
                     _saveChanges();
                }),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // --- TABS ---

  Widget _buildSummaryTab() {
    // Calc breakdown
    final Map<String, double> breakdown = {};
    for (var i in _currentScenario!.items) {
      breakdown[i.category] = (breakdown[i.category] ?? 0) + i.monthlyEquivalent;
    }
    final total = _currentScenario!.totalMonthly;
    final sorted = breakdown.entries.toList()..sort((a,b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Distribución por Categoría', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
           const SizedBox(height: 16),
           ...sorted.map((e) {
             final pct = total > 0 ? (e.value / total) : 0.0;
             return Padding(
               padding: const EdgeInsets.only(bottom: 12),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(e.key, style: GoogleFonts.outfit(color: Colors.white70)),
                       Text('\$${e.value.toStringAsFixed(2)} (${(pct*100).toStringAsFixed(1)}%)', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                     ],
                   ),
                   const SizedBox(height: 6),
                   LinearProgressIndicator( value: pct, color: Colors.teal, backgroundColor: Colors.white10),
                 ],
               ),
             );
           }).toList(),
        ],
      ),
    );
  }

  Widget _buildBreakEvenTab(double totalFixed) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
           Text('Punto de Equilibrio (Break-even)', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
           const SizedBox(height: 4),
           Text('¿Cuánto debes vender para cubrir tus costos fijos?', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
           const SizedBox(height: 24),
           
           Row(
             children: [
               Expanded( child: NeonInput(label: 'Precio por Unidad (\$)', isNumber: true, controller: _priceController,)),
               const SizedBox(width: 16),
               Expanded( child: NeonInput(label: 'Costo Variable Unitario (\$)', isNumber: true, controller: _variableCostController,)),
             ],
           ),
           const SizedBox(height: 16),
           
           ElevatedButton(
             onPressed: () { setState(() {}); }, // Just refresh to calc
             child: const Text('CALCULAR'),
             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
           ),
           
           const SizedBox(height: 24),
           
           Builder(
             builder: (ctx) {
                final double p = double.tryParse(_priceController.text) ?? 0;
                final double cv = double.tryParse(_variableCostController.text) ?? 0;
                
                if (p <= 0 || p <= cv) {
                  return Text('Ingresa un precio mayor al costo variable para ver el resultado.', style: GoogleFonts.outfit(color: Colors.white30), textAlign: TextAlign.center);
                }
                
                final double margin = p - cv;
                final double units = totalFixed / margin;
                final double sales = units * p;
                
                return NeonCard(
                  borderColor: Colors.tealAccent,
                  child: Column(
                    children: [
                      _buildRow('Margen de Contribución', '\$${margin.toStringAsFixed(2)} / ud'),
                      const Divider(color: Colors.white24),
                      _buildMainResult('Unidades a vender', '${units.ceil()} u.'),
                      const SizedBox(height: 8),
                      _buildMainResult('Ventas Totales', '\$${NumberFormat("#,##0.00", "en_US").format(sales)}'),
                    ],
                  ),
                );
             },
           ),
           const SizedBox(height: 12),
           Text('Cálculo simplificado (Fixed / Margen). Úsalo solo como referencia.', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
  
  Widget _buildRow(String k, String v) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 4),
       child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
         Text(k, style: GoogleFonts.outfit(color: Colors.white70)),
         Text(v, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
       ]),
     );
  }
  
  Widget _buildMainResult(String k, String v) {
     return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
         Text(k, style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
         Text(v, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
     ]);
  }

  // --- MODAL ---
  
  void _showEditModal({FixedCostItem? item, String? initialName, String? initialCat, CostFrequency? initialFreq}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditItemModal(
        item: item,
        initialName: initialName,
        initialCat: initialCat,
        initialFreq: initialFreq,
        onSave: (newItem) {
          setState(() {
             if (item != null) {
               final idx = _currentScenario!.items.indexOf(item);
               if (idx != -1) _currentScenario!.items[idx] = newItem;
             } else {
               _currentScenario!.items.add(newItem);
             }
          });
          _saveChanges();
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _EditItemModal extends StatefulWidget {
  final FixedCostItem? item;
  final String? initialName;
  final String? initialCat;
  final CostFrequency? initialFreq;
  final Function(FixedCostItem) onSave;

  const _EditItemModal({Key? key, this.item, required this.onSave, this.initialName, this.initialCat, this.initialFreq}) : super(key: key);

  @override
  __EditItemModalState createState() => __EditItemModalState();
}

class __EditItemModalState extends State<_EditItemModal> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late double _amount;
  late CostFrequency _freq;
  
  @override
  void initState() {
    super.initState();
    _name = widget.item?.name ?? widget.initialName ?? '';
    _category = widget.item?.category ?? widget.initialCat ?? 'General';
    _amount = widget.item?.amount ?? 0;
    _freq = widget.item?.frequency ?? widget.initialFreq ?? CostFrequency.mensual;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 24, left: 24, right: 24
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1520),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Text(widget.item == null ? 'Agregar Costo' : 'Editar Costo', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
             const SizedBox(height: 20),
             
             TextFormField(
               initialValue: _name,
               style: GoogleFonts.outfit(color: Colors.white),
               decoration: InputDecoration(labelText: 'Nombre del gasto', labelStyle: GoogleFonts.outfit(color: Colors.white54)),
               onChanged: (v) => _name = v,
               validator: (v) => v!.isEmpty ? 'Requerido' : null,
             ),
             const SizedBox(height: 12),
             
             DropdownButtonFormField<String>(
               value: ['General', 'Infraestructura', 'RRHH', 'Servicios', 'Legal', 'Software', 'Financiero', 'Marketing'].contains(_category) ? _category : 'General',
               dropdownColor: const Color(0xFF151C2B),
               items: ['General', 'Infraestructura', 'RRHH', 'Servicios', 'Legal', 'Software', 'Financiero', 'Marketing']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.outfit(color: Colors.white)))).toList(),
               onChanged: (v) => setState(() => _category = v!),
               decoration: InputDecoration(labelText: 'Categoría', labelStyle: GoogleFonts.outfit(color: Colors.white54)),
             ), 
             const SizedBox(height: 12),
             
             Row(
               children: [
                 Expanded(
                   flex: 2,
                   child: TextFormField(
                     initialValue: _amount > 0 ? _amount.toString() : '',
                     keyboardType: TextInputType.number,
                     style: GoogleFonts.outfit(color: Colors.white),
                     decoration: InputDecoration(labelText: 'Monto (\$)', labelStyle: GoogleFonts.outfit(color: Colors.white54)),
                     onChanged: (v) => _amount = double.tryParse(v) ?? 0,
                     validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Inválido' : null,
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   flex: 3,
                   child: DropdownButtonFormField<CostFrequency>(
                     value: _freq,
                     dropdownColor: const Color(0xFF151C2B),
                     items: CostFrequency.values
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.label, style: GoogleFonts.outfit(color: Colors.white)))).toList(),
                     onChanged: (v) => setState(() => _freq = v!),
                     decoration: InputDecoration(labelText: 'Frecuencia', labelStyle: GoogleFonts.outfit(color: Colors.white54)),
                   ),
                 ),
               ],
             ),
             
             if (_category == 'Financiero')
                Align(alignment: Alignment.centerLeft, child: TextButton.icon(
                  onPressed: () {}, // Link stub
                  icon: const Icon(Icons.link, size: 14), label: const Text('Abrir Calc. Préstamos'),
                )),

             const SizedBox(height: 32),
             
             ElevatedButton(
               onPressed: () {
                 if (_formKey.currentState!.validate()) {
                   widget.onSave(FixedCostItem(
                     id: widget.item?.id ?? const Uuid().v4(),
                     name: _name,
                     category: _category,
                     frequency: _freq,
                     amount: _amount,
                   ));
                 }
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: const Color(0xFFD4AF37),
                 foregroundColor: Colors.black,
                 padding: const EdgeInsets.symmetric(vertical: 16),
               ),
               child: const Text('GUARDAR'),
             ),
          ],
        ),
      ),
    );
  }
}
