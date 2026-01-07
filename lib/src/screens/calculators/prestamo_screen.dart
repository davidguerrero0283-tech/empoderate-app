import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/widgets/feature_intro_screen.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../components/calculator_info_panel.dart';
import 'dart:math' as math;

class PrestamoScreen extends StatefulWidget {
  const PrestamoScreen({Key? key}) : super(key: key);

  @override
  State<PrestamoScreen> createState() => _PrestamoScreenState();
}

class _PrestamoScreenState extends State<PrestamoScreen> {
  bool _showIntro = true;
  // Use global constants from neon_widgets where possible or define consistent ones
  final Color _neonBlue = const Color(0xFF00C9FF);
  final Color _neonGreen = const Color(0xFF00FF94);
  final Color _neonGold = const Color(0xFFF4D35E);
  final Color _neonRed = const Color(0xFFFF4D4D);

  // Controllers
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _tasaAnualController = TextEditingController();
  final TextEditingController _anosController = TextEditingController();
  final TextEditingController _mesesController = TextEditingController();
  // Additional cost controllers
  final TextEditingController _feciController = TextEditingController();
  final TextEditingController _gastosCierreController = TextEditingController();
  final TextEditingController _otrosCargosController = TextEditingController();
  // Extra payment controllers
  final TextEditingController _extraAmountController = TextEditingController();
  final TextEditingController _extraPeriodController = TextEditingController();

  // Helper to format controller value to two decimals on blur
  void _formatController(TextEditingController controller) {
    final text = controller.text.replaceAll(',', '').trim();
    if (text.isEmpty) return;
    final value = double.tryParse(text);
    if (value != null) {
      controller.text = value.toStringAsFixed(2);
    }
  }

  // Term selection: 0 = años, 1 = meses, 2 = ambos
  int _termMode = 0;
  // Frequency: 0 = mensual, 1 = quincenal, 2 = semanal
  int _freqMode = 0;
  // Extra payment type: 0 = none, 1 = único, 2 = mensual
  int _extraPaymentType = 0;

  // Results
  double _cuota = 0.0;
  double _totalPagado = 0.0;
  double _totalIntereses = 0.0;
  // Extra payment results
  bool _hasExtraResults = false;
  int _newTerm = 0;
  double _newTotalPaid = 0.0;
  double _interestSaved = 0.0;
  // Additional cost values for display
  double _gastosCierre = 0.0;
  double _otrosCargos = 0.0;
  double _tasaAnual = 0.0;
  double _feci = 0.0;
  List<Map<String, String>> _amortizacion = [];
  bool _hasCalculated = false;

  @override
  void dispose() {
    _montoController.dispose();
    _tasaAnualController.dispose();
    _anosController.dispose();
    _mesesController.dispose();
    super.dispose();
  }

  void _calcularPrestamo() {
    // 1. Validate inputs
    String? error;
    if (_montoController.text.isEmpty) {
      error = 'Por favor ingresa el monto del préstamo';
    } else if (_tasaAnualController.text.isEmpty) {
      error = 'Por favor ingresa la tasa de interés anual';
    } else if (_termMode == 0 && _anosController.text.isEmpty) {
        error = 'Por favor ingresa la cantidad de años';
    } else if (_termMode == 1 && _mesesController.text.isEmpty) {
        error = 'Por favor ingresa la cantidad de meses';
    } else if (_termMode == 2 && (_anosController.text.isEmpty && _mesesController.text.isEmpty)) {
        error = 'Por favor ingresa el plazo (años o meses)';
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Parse base inputs
    double principal = double.tryParse(_montoController.text.replaceAll(',', '')) ?? 0.0;
    double tasaAnual = double.tryParse(_tasaAnualController.text.replaceAll(',', '')) ?? 0.0;
    double feci = double.tryParse(_feciController.text.replaceAll(',', '')) ?? 0.0;
    double gastosCierre = double.tryParse(_gastosCierreController.text.replaceAll(',', '')) ?? 0.0;
    double otrosCargos = double.tryParse(_otrosCargosController.text.replaceAll(',', '')) ?? 0.0;

    // Validate numeric values > 0
    if (principal <= 0) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El monto debe ser mayor a 0', style: GoogleFonts.outfit())),
      );
      return;
    }
    
    double tasaTotalAnual = tasaAnual + feci;
    // Determine total periods based on term mode
    int totalPeriods = 0;
    if (_termMode == 0) {
      int anos = int.tryParse(_anosController.text) ?? 0;
      totalPeriods = anos * 12;
    } else if (_termMode == 1) {
      int meses = int.tryParse(_mesesController.text) ?? 0;
      totalPeriods = meses;
    } else {
      int anos = int.tryParse(_anosController.text) ?? 0;
      int meses = int.tryParse(_mesesController.text) ?? 0;
      totalPeriods = anos * 12 + meses;
    }

    if (totalPeriods <= 0) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El plazo total debe ser mayor a 0 meses', style: GoogleFonts.outfit())),
      );
      return;
    }

    // Base monthly rate
    double iMensual = (tasaTotalAnual / 12) / 100.0;
    double i = iMensual; // Default to monthly
    // Adjust logic if rate is 0 (though unusual for loan, handle divide by zero implicitly or small text)
    if (tasaTotalAnual == 0) {
       // Simple division if 0 interest
       i = 0;
    }

    int n = totalPeriods;
    if (_freqMode == 1) { // Quincenal
      i = iMensual / 2;
      n = totalPeriods * 2;
    } else if (_freqMode == 2) { // Semanal
      i = iMensual / 4.3333;
      n = (totalPeriods * 4.3333).round();
    }
    
    // Annuity payment formula: P * i / (1 - (1+i)^-n)
    double cuota = 0.0;
    if (i == 0) {
      cuota = principal / n;
    } else {
      cuota = principal * i / (1 - math.pow(1 + i, -n));
    }
    
    double totalPagado = cuota * n;
    double totalIntereses = totalPagado - principal;
    // Build amortization (first 5 rows)
    List<Map<String, String>> amort = [];
    double saldo = principal;
    for (int period = 1; period <= (n < 5 ? n : 5); period++) {
      double interes = saldo * i;
      double capital = cuota - interes;
      saldo -= capital;
      if (saldo < 0) saldo = 0;
      amort.add({
        'periodo': period.toString(),
        'cuota': cuota.toStringAsFixed(2),
        'interes': interes.toStringAsFixed(2),
        'capital': capital.toStringAsFixed(2),
        'saldo': saldo > 0 ? saldo.toStringAsFixed(2) : '0.00',
      });
    }
    // Extra payment simulation
    double newTotalPaid = totalPagado;
    int newTerm = n;
    double interestSaved = 0.0;
    bool extraCalculated = false;
    if (_extraPaymentType != 0) {
      double extraAmt = double.tryParse(_extraAmountController.text.replaceAll(',', '')) ?? 0.0;
      if (extraAmt > 0) {
        double saldoExtra = principal;
        int periodCount = 0;
        int extraPeriodTarget = int.tryParse(_extraPeriodController.text) ?? 0;

        for (int p = 1; p <= n * 2; p++) { // Limit loop to avoid infinite
          double interes = saldoExtra * i;
          double capital = cuota - interes;
          
          if (_extraPaymentType == 1 && p == extraPeriodTarget) {
            saldoExtra -= extraAmt; 
          } else if (_extraPaymentType == 2) {
            saldoExtra -= extraAmt; 
          }
           
          // Normal payment
          saldoExtra -= capital;
          periodCount++;
          
          if (saldoExtra <= 0.1) { // Threshold for 0
             // Final adjustment effectively
             break;
          }
          // If term exceeds ridiculously, break
          if (periodCount > n && _extraPaymentType == 0) break; 
        }
        
        // Approximate calculation for savings
        if (saldoExtra <= 0.1) {
            newTerm = periodCount;
            // Recalculate totals is complex with varying payments, simplify:
            // Total paid = (Quota * N') + TotalExtras
            double totalExtras = 0;
            if (_extraPaymentType == 1) totalExtras = extraAmt;
            if (_extraPaymentType == 2) totalExtras = extraAmt * newTerm;
            
            newTotalPaid = (cuota * newTerm) + totalExtras; 
             // Correction: The last payment might be partial, but for estimation:
            
            // Interest = TotalPaid - Principal
            double newIntereses = newTotalPaid - principal;
            interestSaved = totalIntereses - newIntereses;
            if (interestSaved < 0) interestSaved = 0;
            
            extraCalculated = true;
        }
      }
    }
    setState(() {
      _cuota = cuota;
      _totalPagado = totalPagado;
      _totalIntereses = totalIntereses;
      _amortizacion = amort;
      _hasCalculated = true;
      _hasExtraResults = extraCalculated;
      _newTerm = newTerm;
      _newTotalPaid = newTotalPaid;
      _interestSaved = interestSaved;
      // Store additional costs for display
      _gastosCierre = gastosCierre;
      _otrosCargos = otrosCargos;
      _tasaAnual = tasaAnual;
      _feci = feci;
    });
  }

  void _clear() {
    setState(() {
      _montoController.clear();
      _tasaAnualController.clear();
      _anosController.clear();
      _mesesController.clear();
      _feciController.clear();
      _gastosCierreController.clear();
      _otrosCargosController.clear();
      _extraAmountController.clear();
      _extraPeriodController.clear();
      _extraPaymentType = 0;
      _hasCalculated = false;
      _hasExtraResults = false;
    });
  }

  String _fmt(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Calculadora de Préstamos',
      useScroll: false,
      usePadding: false,
      body: Stack(
        children: [
          // MAIN CONTENT - wrapped in Positioned.fill
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildTermSelector(),
                const SizedBox(height: 12),
                _buildFrequencyDropdown(),
                const SizedBox(height: 12),
                NeonWideCard(
                  borderColor: _neonBlue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Monto
                      Text('Monto del préstamo', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      NeonInput(
                        label: 'Monto',
                        controller: _montoController,
                        hint: 'Ej: 10,000.00',
                        isNumber: true,
                      ),
                      const SizedBox(height: 8),
                      // Tasa anual
                      Text('Tasa de interés anual (%)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      NeonInput(
                        label: 'Tasa anual',
                        controller: _tasaAnualController,
                        hint: 'Ej: 6.5',
                        isNumber: true,
                        suffixText: '%',
                      ),
                      const SizedBox(height: 12),
                      // Conditional term fields
                      if (_termMode == 0) ...[
                        Text('Cantidad de años', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        NeonInput(
                          label: 'Años',
                          controller: _anosController,
                          hint: 'Ej: 5',
                          isNumber: true,
                        ),
                      ] else if (_termMode == 1) ...[
                        Text('Cantidad de meses', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        NeonInput(
                          label: 'Meses',
                          controller: _mesesController,
                          hint: 'Ej: 60',
                          isNumber: true,
                        ),
                      ] else ...[
                        Text('Años', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        NeonInput(
                          label: 'Años',
                          controller: _anosController,
                          hint: 'Ej: 2',
                          isNumber: true,
                        ),
                        const SizedBox(height: 8),
                        Text('Meses', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        NeonInput(
                          label: 'Meses',
                          controller: _mesesController,
                          hint: 'Ej: 6',
                          isNumber: true,
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Additional Costs Section
                      NeonWideCard(
                        borderColor: _neonBlue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Costos adicionales del préstamo', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            // FECI
                            Text('FECI (tasa anual %)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 4),
                            NeonInput(
                              label: 'FECI',
                              controller: _feciController,
                              hint: 'Ej: 1.00',
                              isNumber: true,
                              suffixText: '%',
                            ),
                            const SizedBox(height: 8),
                            // Gastos de cierre
                            Text('Gastos de cierre (B/.)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 4),
                            NeonInput(
                              label: 'Gastos de cierre',
                              controller: _gastosCierreController,
                              hint: 'Ej: 350.00',
                              isNumber: true,
                            ),
                            const SizedBox(height: 8),
                            // Otros cargos
                            Text('Otros cargos (B/.)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 4),
                            NeonInput(
                              label: 'Otros cargos',
                              controller: _otrosCargosController,
                              hint: 'Ej: 50.00',
                              isNumber: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Extra Payments Section
                      NeonWideCard(
                        borderColor: _neonBlue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pagos extra (opcional)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            DropdownButton<int>(
                              value: _extraPaymentType,
                              dropdownColor: const Color(0xFF001A1A),
                              underline: Container(height: 1, color: Colors.white24),
                              items: const [
                                DropdownMenuItem(value: 0, child: Text('Sin pagos extra', style: TextStyle(color: Colors.white))),
                                DropdownMenuItem(value: 1, child: Text('Pago extra único', style: TextStyle(color: Colors.white))),
                                DropdownMenuItem(value: 2, child: Text('Pago extra mensual', style: TextStyle(color: Colors.white))),
                              ],
                              onChanged: (v) => setState(() { _extraPaymentType = v ?? 0; _hasExtraResults = false; }),
                            ),
                            const SizedBox(height: 8),
                            if (_extraPaymentType == 1) ...[
                              Text('Monto del pago extra (B/.)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 4),
                              NeonInput(
                                label: 'Monto extra',
                                controller: _extraAmountController,
                                hint: 'Ej: 200.00',
                                isNumber: true,
                              ),
                              const SizedBox(height: 8),
                              Text('Número de cuota donde aplicar', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 4),
                              NeonInput(
                                label: 'Cuota',
                                controller: _extraPeriodController,
                                hint: 'Ej: 12',
                                isNumber: true,
                              ),
                            ] else if (_extraPaymentType == 2) ...[
                              Text('Monto extra mensual (B/.)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 4),
                              NeonInput(
                                label: 'Monto extra mensual',
                                controller: _extraAmountController,
                                hint: 'Ej: 100.00',
                                isNumber: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: NeonButton(
                              text: 'Calcular cuota',
                              color: _neonGold,
                              textColor: Colors.black,
                              onTap: _calcularPrestamo,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: NeonButton(
                              text: 'Limpiar campos',
                              color: Colors.white10,
                              textColor: Colors.white,
                              onTap: _clear,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                if (_hasCalculated) _buildResultsCard(),
                const SizedBox(height: 32),
                const CalculatorInfoPanel(configId: 'loan_payment'),
                const SizedBox(height: 80),
              ],
            ),
          ),
          ),

          // --- INTRO OVERLAY ---
          if (_showIntro)
            Positioned.fill(
              child: FeatureIntroScreen(
                key: const ValueKey('IntroOverlay'),
                title: 'CRÉDITO INTELIGENTE',
                subTitle: 'Calcula cuotas, intereses y el ahorro real al realizar abonos a capital.',
                heroEmoji: '💳',
                primaryColor: const Color(0xFF03A9F4), // Light Blue
                features: const [
                  IntroFeatureItem(Icons.payment, 'Cuotas'),
                  IntroFeatureItem(Icons.savings, 'Ahorro'),
                  IntroFeatureItem(Icons.calendar_month, 'Amortización'),
                ],
                processSteps: const [
                  IntroStepItem('1. Datos', 'Monto, tasa y plazo.'),
                  IntroStepItem('2. Extras', 'Simula abonos a capital.'),
                  IntroStepItem('3. Analiza', 'Mira el interés ahorrado.'),
                ],
                proTip: 'Abonar a capital en los primeros años ahorra más intereses.',
                onDismiss: () => setState(() => _showIntro = false),
              ),
            ),

        ],
      ),
    );
  }

  Widget _buildTermSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          _buildTermOption(0, 'Años'),
          _buildTermOption(1, 'Meses'),
          _buildTermOption(2, 'Ambos'),
        ],
      ),
    );
  }

  Widget _buildTermOption(int index, String text) {
    bool selected = _termMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _termMode = index; _hasCalculated = false; }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _neonBlue.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected ? Border.all(color: _neonBlue) : null,
          ),
          alignment: Alignment.center,
          child: Text(text, style: GoogleFonts.outfit(color: selected ? _neonBlue : Colors.white60)),
        ),
      ),
    );
  }

  Widget _buildFrequencyDropdown() {
    return Row(
      children: [
        Text('Frecuencia de pagos', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
        const SizedBox(width: 12),
        DropdownButton<int>(
           value: _freqMode,
           dropdownColor: const Color(0xFF001A1A),
           underline: Container(height: 1, color: Colors.white24),
           items: const [
             DropdownMenuItem(value: 0, child: Text('Mensual', style: TextStyle(color: Colors.white))),
             DropdownMenuItem(value: 1, child: Text('Quincenal', style: TextStyle(color: Colors.white))),
             DropdownMenuItem(value: 2, child: Text('Semanal', style: TextStyle(color: Colors.white))),
           ],
           onChanged: (v) => setState(() { _freqMode = v ?? 0; _hasCalculated = false; }),
        ),
      ],
    );
  }

  Widget _buildResultsCard() {
    return Column(
      children: [
        // 1. Initial Costs Card
        if (_gastosCierre > 0 || _otrosCargos > 0 || _feci > 0)
          NeonWideCard(
            borderColor: _neonRed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assignment_late_outlined, color: _neonRed),
                    const SizedBox(width: 12),
                    Text('Costos Iniciales y Tasas', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                if (_feci > 0) ...[
                  _resultRow('Tasa Base', _tasaAnual, isPercent: true),
                  _resultRow('FECI', _feci, isPercent: true),
                  const Divider(color: Colors.white10),
                  _resultRow('Tasa Total', _tasaAnual + _feci, isPercent: true, isBold: true),
                  const SizedBox(height: 12),
                ],
                if (_gastosCierre > 0) _resultRow('Gastos de cierre', _gastosCierre),
                if (_otrosCargos > 0) _resultRow('Otros cargos', _otrosCargos),
                if (_gastosCierre > 0 || _otrosCargos > 0) ...[
                  const Divider(color: Colors.white10),
                  _resultRow('Total costos iniciales', _gastosCierre + _otrosCargos, isBold: true),
                ],
              ],
            ),
          ),
        const SizedBox(height: 16),
        // 2. Main Loan Results
        NeonWideCard(
          borderColor: _neonGreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, color: _neonGreen),
                  const SizedBox(width: 12),
                  Text('Resultado del Préstamo', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(color: Colors.white24, height: 32),
              _resultRow('Cuota Mensual', _cuota, isBold: true, color: _neonGreen),
              _resultRow('Total a Pagar (Cuotas)', _totalPagado),
              _resultRow('Total Intereses', _totalIntereses),
              if (_gastosCierre > 0 || _otrosCargos > 0) ...[
                const Divider(color: Colors.white24),
                _resultRow('Costo Total (Inc. Iniciales)', _totalPagado + _gastosCierre + _otrosCargos, isBold: true),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 3. Extra Payments Comparison
        if (_hasExtraResults)
          NeonWideCard(
            borderColor: _neonBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.compare_arrows, color: _neonBlue),
                    const SizedBox(width: 12),
                    Text('Impacto de Pagos Extra', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                
                // Original vs New Table
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1), 
                  },
                  children: [
                    TableRow(
                      children: [
                        const SizedBox(),
                        Text('Original', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12), textAlign: TextAlign.center),
                        Text('Con Extra', style: GoogleFonts.outfit(color: _neonBlue, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ]
                    ),
                    const TableRow(children: [SizedBox(height: 8), SizedBox(height: 8), SizedBox(height: 8)]),
                    TableRow(
                      children: [
                        Text('Plazo (meses)', style: GoogleFonts.outfit(color: Colors.white70)),
                        Text('${_amortizacion.length > 0 ? _amortizacion.length : _termMode == 0 ? (int.tryParse(_anosController.text) ?? 0) * 12 : (int.tryParse(_mesesController.text) ?? 0)}', style: GoogleFonts.outfit(color: Colors.white), textAlign: TextAlign.center),
                        Text('$_newTerm', style: GoogleFonts.outfit(color: _neonBlue, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ]
                    ),
                    const TableRow(children: [SizedBox(height: 8), SizedBox(height: 8), SizedBox(height: 8)]),
                    TableRow(
                      children: [
                        Text('Total Intereses', style: GoogleFonts.outfit(color: Colors.white70)),
                        Text( _fmt(_totalIntereses), style: GoogleFonts.outfit(color: Colors.white), textAlign: TextAlign.center),
                        Text( _fmt(_totalIntereses - _interestSaved), style: GoogleFonts.outfit(color: _neonBlue, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ]
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ahorro en Intereses:', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('B/. ${_fmt(_interestSaved)}', style: GoogleFonts.outfit(color: _neonGreen, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('↳ La cuota base se mantiene igual, el pago extra se aplica al capital reduciendo el plazo.', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          
        if (_amortizacion.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Ejemplo de amortización (primeras filas)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          NeonWideCard(
             borderColor: Colors.white12,
             child: Column(
                children: _amortizacion.map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${row['periodo']}', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                      Text('Cuota: ${row['cuota']}', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
                      Text('Int: ${row['interes']}', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
                      Text('Cap: ${row['capital']}', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
                    ]
                  ),
                )).toList(),
             ),
          ),
        ]
      ],
    );
  }

  Widget _resultRow(String label, double amount, {bool isBold = false, Color? color, bool isPercent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          Text(
            isPercent ? '${_fmt(amount)} %' : 'B/. ${_fmt(amount)}', 
            style: GoogleFonts.outfit(
              color: color ?? (isBold ? Colors.white : Colors.white70), 
              fontWeight: isBold ? FontWeight.bold : FontWeight.w400, 
              fontSize: 16
            )
          ),
        ],
      ),
    );
  }


}
