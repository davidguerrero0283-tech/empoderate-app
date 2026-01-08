import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import '../../../components/premium_scaffold.dart';
import '../../../components/calculator_info_panel.dart';
import '../../../features/accounting/accounting_repository.dart';
import '../../../data/repositories/checklist_repository.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  bool _isBusinessMode = true;

  final TextEditingController _incomeCtrl = TextEditingController();
  
  // Personal (Legacy)
  final TextEditingController _needsCtrl = TextEditingController(); 
  final TextEditingController _wantsCtrl = TextEditingController(); 
  final TextEditingController _savingsCtrl = TextEditingController(); 

  // Business (New)
  final TextEditingController _varCostsCtrl = TextEditingController();
  final TextEditingController _fixedCostsCtrl = TextEditingController();
  final TextEditingController _opsCostsCtrl = TextEditingController();
  final TextEditingController _taxResCtrl = TextEditingController();
  final TextEditingController _utilityCtrl = TextEditingController();

  double _totalSpent = 0.0;
  bool _calculated = false;

  @override
  void initState() {
    super.initState();
    // Force business mode logic or simple load previous values if any
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
       _incomeCtrl.text = prefs.getString('acc_budget_income') ?? '';
       _isBusinessMode = prefs.getBool('acc_budget_is_business') ?? true;
       // Load others if needed, for now focusing on Signal
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('acc_budget_income', _incomeCtrl.text);
    // Always business
    
    // Save Result to Repo if calculated
    if (_calculated && _totalSpent > 0) {
      await AccountingRepository().saveResult(AccountingRepository.typeBudget, {
        'income': _incomeCtrl.text,
        'totalSpent': _totalSpent,
        'utilidad': _utilityCtrl.text,
        'isBusiness': true
      });
      // Refresh Progress
      await ChecklistRepository().refresh();
    }
  }

  void _calculate() {
    setState(() {
      _calculated = true;
      if (_isBusinessMode) {
        final varC = double.tryParse(_varCostsCtrl.text) ?? 0.0;
        final fixC = double.tryParse(_fixedCostsCtrl.text) ?? 0.0;
        final opsC = double.tryParse(_opsCostsCtrl.text) ?? 0.0;
        final taxC = double.tryParse(_taxResCtrl.text) ?? 0.0;
        final util = double.tryParse(_utilityCtrl.text) ?? 0.0;
        _totalSpent = varC + fixC + opsC + taxC + util;
      } else {
        final needs = double.tryParse(_needsCtrl.text) ?? 0.0;
        final wants = double.tryParse(_wantsCtrl.text) ?? 0.0;
        final savings = double.tryParse(_savingsCtrl.text) ?? 0.0;
        _totalSpent = needs + wants + savings;
      }
    });
    _saveState();
  }

  void _autoAdjust() {
    final income = double.tryParse(_incomeCtrl.text) ?? 0.0;
    if (income <= 0) return;
    
    if (_isBusinessMode) {
       final varC = double.tryParse(_varCostsCtrl.text) ?? 0.0;
       final fixC = double.tryParse(_fixedCostsCtrl.text) ?? 0.0;
       final opsC = double.tryParse(_opsCostsCtrl.text) ?? 0.0;
       final taxC = double.tryParse(_taxResCtrl.text) ?? 0.0;
       
       final currentAlloc = varC + fixC + opsC + taxC;
       if (currentAlloc < income) {
         _utilityCtrl.text = (income - currentAlloc).toStringAsFixed(2);
       }
    }
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Presupuesto de Negocio',
      isNeonTitle: true,
      showBackButton: true,
      body: Stack(
        children: [
          // MAIN CONTENT - wrapped in Positioned.fill
          Positioned.fill(
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CalculatorInfoPanel(configId: 'budget'),
                const SizedBox(height: 24),

                _buildNeonInput(controller: _incomeCtrl, label: _isBusinessMode ? 'Ingresos del mes' : 'Ingreso Mensual Total', icon: Icons.attach_money, hint: 'Ej: 5000.00'),
                const SizedBox(height: 12),
                _buildSectionTitle(_isBusinessMode ? 'Distribución Operativa' : 'Distribución Real (Lo que gastas hoy)'),
                
                // Only inputs for business
                   _buildNeonInput(controller: _varCostsCtrl, label: 'Costos Variables (Insumos/Comisión)', icon: Icons.inventory_2_outlined, hint: 'Ej: 1500.00', color: Colors.blueAccent),
                   const SizedBox(height: 8),
                   _buildNeonInput(controller: _fixedCostsCtrl, label: 'Gastos Fijos (Alquiler/Planilla)', icon: Icons.store_outlined, hint: 'Ej: 1200.00', color: Colors.orangeAccent),
                   const SizedBox(height: 8),
                   _buildNeonInput(controller: _opsCostsCtrl, label: 'Operación y Ventas (Mkt/Software)', icon: Icons.settings_outlined, hint: 'Ej: 500.00', color: Colors.purpleAccent),
                   const SizedBox(height: 8),
                   _buildNeonInput(controller: _taxResCtrl, label: 'Impuestos y Tasas (Reserva)', icon: Icons.account_balance_outlined, hint: 'Ej: 300.00', color: Colors.redAccent),
                   const SizedBox(height: 8),
                   _buildNeonInput(controller: _utilityCtrl, label: 'Utilidad Neta / Reserva', icon: Icons.trending_up, hint: 'Ej: 1500.00', color: Colors.greenAccent),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _calculate,
                        style: _actionButtonStyle(),
                        child: Text('CALCULAR', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ),
                    ),
                    if (_isBusinessMode) ...[
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _autoAdjust,
                        icon: const Icon(Icons.auto_fix_high, color: Color(0xFFAED581)),
                        tooltip: 'Ajustar sobrante a Utilidad',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFAED581).withOpacity(0.1),
                          side: const BorderSide(color: Color(0xFFAED581)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.all(16)
                        ),
                      )
                    ]
                  ],
                ),

                const SizedBox(height: 32),
                if (_calculated) _buildResults(),

                const SizedBox(height: 80),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String text, bool isBusiness) {
    final isSelected = _isBusinessMode == isBusiness;
    return GestureDetector(
      onTap: () => setState(() { 
        _isBusinessMode = isBusiness; 
        _calculated = false; 
        _totalSpent = 0;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFAED581) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.black : Colors.white60,
              fontWeight: FontWeight.bold,
              fontSize: 12
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final double income = double.tryParse(_incomeCtrl.text) ?? 0.0;
    if (income == 0) return const SizedBox.shrink();

    // Data prep
    final Map<String, double> data = {}; 
    final Map<String, Color> colors = {};
    
    if (_isBusinessMode) {
       data['Variable'] = double.tryParse(_varCostsCtrl.text) ?? 0.0;
       data['Fijo'] = double.tryParse(_fixedCostsCtrl.text) ?? 0.0;
       data['Operación'] = double.tryParse(_opsCostsCtrl.text) ?? 0.0;
       data['Impuestos'] = double.tryParse(_taxResCtrl.text) ?? 0.0;
       data['Utilidad'] = double.tryParse(_utilityCtrl.text) ?? 0.0;

       colors['Variable'] = Colors.blueAccent;
       colors['Fijo'] = Colors.orangeAccent;
       colors['Operación'] = Colors.purpleAccent;
       colors['Impuestos'] = Colors.redAccent;
       colors['Utilidad'] = Colors.greenAccent;
    } else {
       data['Necesidades'] = double.tryParse(_needsCtrl.text) ?? 0.0;
       data['Deseos'] = double.tryParse(_wantsCtrl.text) ?? 0.0;
       data['Ahorro'] = double.tryParse(_savingsCtrl.text) ?? 0.0;

       colors['Necesidades'] = Colors.blueAccent;
       colors['Deseos'] = Colors.purpleAccent;
       colors['Ahorro'] = Colors.greenAccent;
    }

    final remaining = income - _totalSpent;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: CustomPaint(
            painter: _DonutChartPainter(
              data: data,
              colors: colors,
              total: income, // Use income as base for full circle if needed, or sum of parts
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('\$${_totalSpent.toStringAsFixed(0)}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('de \$${income.toStringAsFixed(0)}', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        ...data.entries.map((e) => _buildLegendItem(
           e.key, 
           (e.value / income) * 100, 
           _isBusinessMode ? 0 : (e.key == 'Necesidades' ? 50 : (e.key == 'Deseos' ? 30 : 20)), // Personal targets
           colors[e.key]!
        )).toList(),

        if (remaining.abs() > 0.01)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: remaining > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: remaining > 0 ? Colors.green : Colors.red),
              ),
              child: Text(
                remaining > 0 ? 'Te faltan \$${remaining.toStringAsFixed(2)} por asignar' : 'Te pasaste por \$${remaining.abs().toStringAsFixed(2)}',
                style: GoogleFonts.outfit(color: remaining > 0 ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )
          )
        else if (_isBusinessMode)
           _buildBusinessSummary(data, income),
      ],
    );
  }

  Widget _buildBusinessSummary(Map<String, double> data, double income) {
    final util = data['Utilidad'] ?? 0;
    final fixed = data['Fijo'] ?? 0;
    final margin = (util / income) * 100;
    final fixedBurden = (fixed / income) * 100;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Utilidad Estimada', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                   Text('\$${util.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                 ],
               ),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                   Text('Margen Neto', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                   Text('${margin.toStringAsFixed(1)}%', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                 ],
               ),
            ],
          ),
          const SizedBox(height: 12),
          if (fixed > (income * 0.4)) 
             Row(
               children: [
                 Icon(Icons.warning_amber, color: Colors.orangeAccent, size: 16),
                 const SizedBox(width: 8),
                 Expanded(child: Text('Alerta: Gastos fijos altos (${fixed.toStringAsFixed(1)}%). Intenta mantenerlos bajo 30-40%.', style: GoogleFonts.outfit(color: Colors.orangeAccent, fontSize: 11))),
               ],
             )
        ],
      ),
    );
  }
  
  // Reused helpers
  Widget _buildLegendItem(String label, double actual, double target, Color color) {
    // Only show target logic for Personal mode
    final diff = actual - target;
    final showTarget = !_isBusinessMode; 

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: GoogleFonts.outfit(color: Colors.white70))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${actual.toStringAsFixed(1)}%', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              if (showTarget)
                Text(
                  'Meta: $target% (${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}%)',
                  style: GoogleFonts.outfit(color: diff.abs() > 5 ? (diff > 0 && label != 'Ahorro' ? Colors.redAccent : Colors.white24) : Colors.white24, fontSize: 10),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildNeonInput({required TextEditingController controller, required String label, required IconData icon, required String hint, Color color = Colors.white}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: Colors.white54),
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.white24),
          prefixIcon: Icon(icon, color: color.withOpacity(0.7), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
  ButtonStyle _actionButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFAED581).withOpacity(0.2), 
      foregroundColor: const Color(0xFFAED581),
      padding: const EdgeInsets.symmetric(vertical: 16),
      side: const BorderSide(color: Color(0xFFAED581), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double total;

  _DonutChartPainter({required this.data, required this.colors, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;
    final strokeWidth = 20.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()..color = Colors.white10..style = PaintingStyle.stroke..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    double startAngle = -pi / 2;

    for (final entry in data.entries) {
       final pct = (entry.value / total) * 100;
       if (pct > 0) {
          _drawSegment(canvas, rect, startAngle, pct, colors[entry.key] ?? Colors.grey, strokeWidth);
          startAngle += (pct / 100) * 2 * pi;
       }
    }
  }

  void _drawSegment(Canvas canvas, Rect rect, double startAngle, double pct, Color color, double strokeWidth) {
    if (pct <= 0) return;
    final sweepAngle = (pct / 100) * 2 * pi;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
