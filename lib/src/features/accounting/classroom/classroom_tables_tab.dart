import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/features/accounting/classroom/accounting_class_data.dart';

class ClassroomTablesTab extends StatefulWidget {
  const ClassroomTablesTab({Key? key}) : super(key: key);

  @override
  @override
  State<ClassroomTablesTab> createState() => _ClassroomTablesTabState();
}

class _ClassroomTablesTabState extends State<ClassroomTablesTab> {
  Map<String, dynamic>? _currentData;
  String _selectedExampleName = 'Selecciona un ejemplo';

  @override
  void initState() {
    super.initState();
    // Auto-load default example for better UX
    _loadExample('retail'); 
  }

  void _loadExample(String key) {
    setState(() {
      _currentData = AccountingClassData.exampleDatasets[key];
      _selectedExampleName = _currentData!['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CONTROL PANEL
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildExampleButton('Retail / Tienda', 'retail', Colors.blueAccent),
                const SizedBox(width: 8),
                _buildExampleButton('Restaurante', 'restaurant', Colors.orangeAccent),
                const SizedBox(width: 8),
                _buildExampleButton('Servicios', 'services', Colors.purpleAccent),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Ejemplo Cargado: $_selectedExampleName',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          if (_currentData != null) ...[
            _buildSectionTitle('1. Presupuesto vs Realidad', Colors.cyanAccent),
            _buildBudgetTable(_currentData!['budgetVsReal']),
             _buildInterpretation('¿Qué significa?', [
              'La Variación te dice cuánto te alejaste del plan.',
              'Negativo en "Ventas" es malo (vendiste menos).',
              'Negativo en "Gastos" es bueno (ahorraste dinero).'
            ]),
            const SizedBox(height: 32),

            _buildSectionTitle('2. Indicadores Clave (KPIs)', Colors.greenAccent),
            _buildKpiTable(_currentData!['kpis']),
             _buildInterpretation('¿Qué significa?', [
              'Estos números resumen la salud de tu negocio.',
              'Compara siempre "Actual" vs "Meta".',
              'Si está rojo, actúa de inmediato.'
            ]),
            const SizedBox(height: 32),

            // Simplified Cost Table constructed from single fields just for demo
             _buildSectionTitle('3. Estructura de Costos', Colors.pinkAccent),
             _buildCostStructureTable(),
             _buildInterpretation('Análisis Rápido', [
               'Costos Fijos: Se pagan vendas o no.',
               'Costo Variable: Sube si vendes mas.',
             ]),

          ] else ...[
             const Center(
               child: Padding(
                 padding: EdgeInsets.all(40.0),
                 child: Text('Toca un botón arriba para cargar datos de ejemplo.', style: TextStyle(color: Colors.white54)),
               ),
             )
          ]
        ],
      ),
    );
  }

  Widget _buildExampleButton(String label, String key, Color color) {
    return GestureDetector(
      onTap: () => _loadExample(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 4)],
        ),
        child: Text(label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(color: color, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInterpretation(String title, List<String> points) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Colors.yellowAccent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          ...points.map((p) => Text('• $p', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildBudgetTable(List<dynamic> rows) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2), // Rubro
          1: FlexColumnWidth(1.2), // Presup
          2: FlexColumnWidth(1.2), // Real
          3: FlexColumnWidth(1.2), // Var
        },
        border: TableBorder(horizontalInside: BorderSide(color: Colors.white10)),
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(color: Colors.white10),
            children: [
              _buildCell('Rubro', isHeader: true),
              _buildCell('Plan', isHeader: true),
              _buildCell('Real', isHeader: true),
              _buildCell('Diff', isHeader: true),
            ],
          ),
          // Data
          ...rows.map((row) {
             final pres = (row['presupuesto'] as num).toDouble();
             final real = (row['real'] as num).toDouble();
             final diff = real - pres;
             // Logic: Income (Sales) -> Positive Diff is Good. Expense -> Negative Diff is Good.
             // Simplified generic logic: Just show raw diff.
             final color = diff >= 0 ? Colors.greenAccent : Colors.redAccent;
             
             return TableRow(
               children: [
                 _buildCell(row['rubro']),
                 _buildCell('\$${pres.toStringAsFixed(0)}'),
                 _buildCell('\$${real.toStringAsFixed(0)}'),
                 _buildCell('\$${diff.toStringAsFixed(0)}', color: color),
               ],
             );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildKpiTable(List<dynamic> rows) {
    return Container(
       decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.5), // KPI
          1: FlexColumnWidth(2), // Formula
          2: FlexColumnWidth(1), // Meta
          3: FlexColumnWidth(1), // Actual
        },
        border: TableBorder(horizontalInside: BorderSide(color: Colors.white10)),
        children: [
           TableRow(
            decoration: BoxDecoration(color: Colors.white10),
            children: [
              _buildCell('KPI', isHeader: true),
              _buildCell('Fórmula', isHeader: true),
              _buildCell('Meta', isHeader: true),
              _buildCell('Real', isHeader: true),
            ],
          ),
           ...rows.map((row) {
             final status = row['status'];
             final color = status == 'ok' ? kNeonGreen : (status == 'warning' ? Colors.orangeAccent : Colors.redAccent);

             return TableRow(
               children: [
                 _buildCell(row['kpi']),
                 _buildCell(row['formula'], fontSize: 11),
                 _buildCell(row['meta']),
                 _buildCell(row['actual'], color: color, isBold: true),
               ],
             );
          }).toList(),
        ],
      ),
    );
  }

    Widget _buildCostStructureTable() {
    // Constructing a table from the flat single example fields
    final fixed = _currentData!['fixedCosts'];
    final varPct = (_currentData!['varCostPct'] as double) * 100;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        border: TableBorder(horizontalInside: BorderSide(color: Colors.white10)),
        children: [
           TableRow(
            decoration: BoxDecoration(color: Colors.white10),
            children: [
              _buildCell('Tipo de Costo', isHeader: true),
              _buildCell('Valor Ejemplo', isHeader: true),
              _buildCell('Notas', isHeader: true),
            ],
          ),
          TableRow(
             children: [
               _buildCell('Costos Fijos Totales'),
               _buildCell('\$${fixed.toString()}'),
               _buildCell('Alquiler, Nómina fija, Luz...'),
             ],
           ),
           TableRow(
             children: [
               _buildCell('Costo Variable %'),
               _buildCell('${varPct.toStringAsFixed(0)}%'),
               _buildCell('Insumos, Comisión...'),
             ],
           ),
        ],
      ),
    );
  }


  Widget _buildCell(String text, {bool isHeader = false, Color? color, bool isBold = false, double fontSize = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: color ?? (isHeader ? Colors.white : Colors.white70),
          fontWeight: (isHeader || isBold) ? FontWeight.bold : FontWeight.normal,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
