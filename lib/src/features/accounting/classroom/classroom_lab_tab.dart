import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/features/accounting/classroom/accounting_class_data.dart';

class ClassroomLabTab extends StatefulWidget {
  const ClassroomLabTab({Key? key}) : super(key: key);

  @override
  State<ClassroomLabTab> createState() => _ClassroomLabTabState();
}

class _ClassroomLabTabState extends State<ClassroomLabTab> {
  final _currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);
  
  // State
  double _monthlySales = 5000;
  double _varCostPct = 0.40; // 40%
  double _fixedCosts = 2000;

  // History
  final List<Map<String, dynamic>> _savedScenarios = [];

  void _loadPreset(String key) {
    final data = AccountingClassData.exampleDatasets[key];
    if (data != null) {
      setState(() {
        _monthlySales = (data['sales'] as num).toDouble();
        _varCostPct = (data['varCostPct'] as num).toDouble();
        _fixedCosts = (data['fixedCosts'] as num).toDouble();
      });
    }
  }

  void _saveScenario() {
    final now = DateTime.now();
    final margin = _monthlySales * (1 - _varCostPct);
    final profit = margin - _fixedCosts;
    
    setState(() {
      _savedScenarios.insert(0, {
        'time': DateFormat('HH:mm').format(now),
        'sales': _monthlySales,
        'profit': profit,
      });
      if (_savedScenarios.length > 5) _savedScenarios.removeLast();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escenario guardado en historial local.')));
  }

  @override
  Widget build(BuildContext context) {
    // Calculations
    final varCosts = _monthlySales * _varCostPct;
    final grossMargin = _monthlySales - varCosts;
    final netFlow = grossMargin - _fixedCosts;
    final breakEven = _varCostPct < 1.0 ? _fixedCosts / (1 - _varCostPct) : 0.0;
    
    // Status Color
    Color statusColor = Colors.grey;
    String statusText = '';
    if (netFlow > 0) {
      statusColor = kNeonGreen;
      statusText = 'RENTABLE';
    } else if (netFlow > -500) {
      statusColor = Colors.yellowAccent;
      statusText = 'RIESGO';
    } else {
      statusColor = kNeonRed;
      statusText = 'PÉRDIDA';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRESETS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetChip('Cargar Retail', () => _loadPreset('retail'), Colors.blueAccent),
                _buildPresetChip('Cargar Restaurante', () => _loadPreset('restaurant'), Colors.orangeAccent),
                _buildPresetChip('Cargar Servicios', () => _loadPreset('services'), Colors.purpleAccent),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // CONTROLS
          NeonCard(
            borderColor: Colors.white24,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSliderControl(
                    label: 'Ventas Mensuales',
                    value: _monthlySales,
                    min: 0, max: 50000, divisions: 100,
                    prefix: '\$',
                    onChanged: (v) => setState(() => _monthlySales = v),
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                   _buildSliderControl(
                    label: 'Costo Variable % (Insumos)',
                    value: _varCostPct * 100,
                    min: 0, max: 100, divisions: 100,
                    suffix: '%',
                    onChanged: (v) => setState(() => _varCostPct = v / 100),
                    color: Colors.pinkAccent,
                  ),
                  const SizedBox(height: 20),
                   // Input optional for fixed costs, using Slider for consistency in "Simulator" feel
                   _buildSliderControl(
                    label: 'Costos Fijos (Alquiler)',
                    value: _fixedCosts,
                    min: 0, max: 20000, divisions: 200,
                    prefix: '\$',
                    onChanged: (v) => setState(() => _fixedCosts = v),
                    color: Colors.cyanAccent,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // RESULTS DASHBOARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
            ),
            child: Column(
              children: [
                Text('RESULTADO NETO ESTIMADO', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, letterSpacing: 1)),
                const SizedBox(height: 8),
                Text(
                  _currencyFormat.format(netFlow),
                  style: GoogleFonts.outfit(color: statusColor, fontSize: 42, fontWeight: FontWeight.bold),
                ),
                Text(statusText, style: GoogleFonts.outfit(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                Divider(color: statusColor.withOpacity(0.2)),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildResultItem('Margen Bruto', _currencyFormat.format(grossMargin)),
                    _buildResultItem('Punto Equilibrio', _currencyFormat.format(breakEven)),
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // SAVE BUTTON
          Center(
            child: NeonButton(
              text: 'GUARDAR ESCENARIO',
              icon: Icons.save,
              onTap: _saveScenario,
              color: Colors.white,
              // padding not supported
            ),
          ),
          
           const SizedBox(height: 24),

          if (_savedScenarios.isNotEmpty) ...[
            Text('Historial Reciente (Sesión Actual)', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 8),
            ..._savedScenarios.map((s) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.history, color: Colors.white24),
              title: Text('Ventas: ${_currencyFormat.format(s['sales'])}', style: TextStyle(color: Colors.white)),
              trailing: Text(
                _currencyFormat.format(s['profit']),
                style: TextStyle(color: (s['profit'] as double) >= 0 ? kNeonGreen : kNeonRed, fontWeight: FontWeight.bold),
              ),
            )).toList(),
          ]
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label, style: const TextStyle(color: Colors.white)),
        backgroundColor: color.withOpacity(0.2),
        side: BorderSide(color: color),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildSliderControl({
    required String label, 
    required double value, 
    required double min, 
    required double max, 
    required Function(double) onChanged,
    int? divisions,
    String? prefix,
    String? suffix,
    Color color = Colors.white
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.outfit(color: Colors.white70)),
            Text(
              '${prefix ?? ''}${value.toStringAsFixed(0)}${suffix ?? ''}',
              style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: color,
          inactiveColor: Colors.white10,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
