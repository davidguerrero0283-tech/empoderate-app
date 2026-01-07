import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/widgets/feature_intro_screen.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../components/calculator_info_panel.dart';

class ItbmsScreen extends StatefulWidget {
  const ItbmsScreen({Key? key}) : super(key: key);

  @override
  State<ItbmsScreen> createState() => _ItbmsScreenState();
}

class _ItbmsScreenState extends State<ItbmsScreen> {
  bool _showIntro = true;
  // 0: Calcular ITBMS (Precio SIN impuesto)
  // 1: Desglosar ITBMS (Precio CON impuesto)
  int _selectedMode = 0;
  
  // Rate handling
  double _taxRate = 0.07; // Default 7%
  final TextEditingController _rateController = TextEditingController(text: '7.00');
  
  // Amount handling
  final TextEditingController _amountController = TextEditingController();

  // Results
  double _baseAmount = 0.0;
  double _taxAmount = 0.0;
  double _totalAmount = 0.0;
  bool _hasCalculated = false;

  @override
  void dispose() {
    _rateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _calculate() {
    // Parse Rate
    double? rateInput = double.tryParse(_rateController.text);
    if (rateInput == null) return; 
    _taxRate = rateInput / 100.0;

    // Parse Amount
    double? amountInput = double.tryParse(_amountController.text);
    if (amountInput == null) {
      setState(() {
        _baseAmount = 0.0;
        _taxAmount = 0.0;
        _totalAmount = 0.0;
        _hasCalculated = false;
      });
      return;
    }

    setState(() {
      if (_selectedMode == 0) {
        // Mode 1: Net to Gross
        _baseAmount = amountInput;
        _taxAmount = _baseAmount * _taxRate;
        _totalAmount = _baseAmount + _taxAmount;
      } else {
        // Mode 2: Gross to Net
        _totalAmount = amountInput;
        _baseAmount = _totalAmount / (1 + _taxRate);
        _taxAmount = _totalAmount - _baseAmount;
      }
      _hasCalculated = true;
    });
  }

  void _clearFields() {
    setState(() {
      _amountController.clear();
      _rateController.text = '7.00';
      _taxRate = 0.07;
      _baseAmount = 0.0;
      _taxAmount = 0.0;
      _totalAmount = 0.0;
      _hasCalculated = false;
    });
  }

  // Auto-format on focus loss
  void _formatCurrencyInput(TextEditingController controller) {
    if (controller.text.isEmpty) return;
    double? value = double.tryParse(controller.text);
    if (value != null) {
      controller.text = value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Calculadora ITBMS',
      useScroll: false,
      usePadding: false,
      body: Stack(
        children: [
          // MAIN CONTENT - wrapped in Positioned.fill
          Positioned.fill(
            child: SingleChildScrollView(
            child: Column(
              children: [
                // 1. Selector de Modo
                _buildModeSelector(),
                const SizedBox(height: 12),
                _buildModeExplanation(),
                const SizedBox(height: 12),

                // 2. Formulario
                NeonWideCard(
                  borderColor: const Color(0xFF00C9FF),
                  backgroundColor: const Color(0xFF0D1F24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       _buildRateSelector(),
                       const SizedBox(height: 24),
                       
                        Text(
                          _selectedMode == 0 
                            ? 'Precio sin ITBMS' 
                            : 'Precio con ITBMS incluido',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                       const SizedBox(height: 8),
                       Focus(
                         onFocusChange: (hasFocus) {
                           if (!hasFocus) _formatCurrencyInput(_amountController);
                         },
                         child: NeonInput(
                           label: 'Monto',
                           controller: _amountController,
                           hint: _selectedMode == 0 ? 'Ej: 100.00' : 'Ej: 107.00',
                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
                           onChanged: (_) {},
                         ),
                       ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedMode == 0
                            ? 'Ingrese el valor neto de la venta, sin incluir ITBMS (en B/.)'
                            : 'Ingrese el total que ya incluye ITBMS (en B/.)',
                          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                        ),

                       const SizedBox(height: 32),
                       Row(
                         children: [
                           Expanded(
                             child: NeonButton(
                               text: 'Calcular',
                               color: const Color(0xFFF4D35E),
                               textColor: Colors.black,
                               onTap: _calculate,
                             ),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: NeonButton(
                               text: 'Limpiar',
                               color: Colors.white10,
                               textColor: Colors.white,
                               onTap: _clearFields,
                             ),
                           ),
                         ],
                       ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 3. Resultados
                if (_hasCalculated) _buildResultsCard(),

                const SizedBox(height: 32),

                // 4. Explicación Docente
                const CalculatorInfoPanel(configId: 'itbms'),

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
                title: 'CALCULADORA ITBMS',
                subTitle: 'Calcula el impuesto de transferencia de bienes muebles o desglósalo del precio final.',
                heroEmoji: '🧾',
                primaryColor: const Color(0xFFE57373), // Red
                features: const [
                  IntroFeatureItem(Icons.receipt, 'Facturación'),
                  IntroFeatureItem(Icons.percent, 'Tasas'),
                  IntroFeatureItem(Icons.calculate, 'Desglose'),
                ],
                processSteps: const [
                  IntroStepItem('1. Tasa', 'Selecciona 7%, 10% o 15%.'),
                  IntroStepItem('2. Modo', 'Calcular o desglosar.'),
                  IntroStepItem('3. Resultado', 'Obtén base e impuesto.'),
                ],
                proTip: '7% para la mayoría, 10% hospedaje/alcohol, 15% tabaco.',
                onDismiss: () => setState(() => _showIntro = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          _buildModeOption(0, 'Calcular (+ITBMS)'),
          _buildModeOption(1, 'Desglosar (-ITBMS)'),
        ],
      ),
    );
  }

  Widget _buildModeOption(int index, String text) {
    bool isSelected = _selectedMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMode = index;
            _calculate(); // Recalculate if switching modes
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00C9FF).withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: const Color(0xFF00C9FF)) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: isSelected ? const Color(0xFF00C9FF) : Colors.white60,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tasa de ITBMS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // Chips with explanations
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRateChip('7%', 'Tasa general (la mayoría de bienes y servicios).'),
            _buildRateChip('10%', 'Bebidas alcohólicas y servicios de hospedaje.'),
            _buildRateChip('15%', 'Productos de tabaco.'),
          ],
        ),
        const SizedBox(height: 12),
        // Custom rate field
        Text('Tasa personalizada', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text('Use este campo solo si aplica una tasa distinta.', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextField(
            controller: _rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.outfit(color: Colors.white),
            decoration: InputDecoration(
              suffixText: '%',
              suffixStyle: const TextStyle(color: Colors.white70),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.black45,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF00C9FF)),
              ),
            ),
            onChanged: (val) {
              double? parsed = double.tryParse(val);
              if (parsed != null) {
                _taxRate = parsed / 100.0;
              }
            },
          ),
        ),
      ],
    );
  }

  // Helper widget for rate chip with description
  Widget _buildRateChip(String label, String description) {
    bool isActive = _rateController.text == double.parse(label.replaceAll('%', '')).toStringAsFixed(2);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _rateController.text = double.parse(label.replaceAll('%', '')).toStringAsFixed(2);
              _calculate();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label, style: GoogleFonts.outfit(color: isActive ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(description, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }

  // Explanation widget for selected mode
  Widget _buildModeExplanation() {
    if (_selectedMode == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Modo: Calcular ITBMS', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Use este modo cuando tiene un precio SIN ITBMS y desea sumar el impuesto para saber el total a cobrar.', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Modo: Desglosar ITBMS', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Use este modo cuando ya tiene un precio FINAL que incluye ITBMS y desea separar cuánto es base y cuánto es impuesto. Ejemplo: si el total pagado fue B/.107.00, el sistema mostrará B/.100.00 de venta y B/.7.00 de ITBMS.', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
        ],
      );
    }
  }

  Widget _buildQuickRateBtn(String label) {
    bool isActive = _rateController.text == double.parse(label.replaceAll('%', '')).toStringAsFixed(2);
    // Simple check, or just make them preset setters
    return GestureDetector(
      onTap: () {
        setState(() {
          _rateController.text = double.parse(label.replaceAll('%', '')).toStringAsFixed(2);
          _calculate();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isActive ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return NeonWideCard(
      borderColor: const Color(0xFF00FF94),
      backgroundColor: const Color(0xFF001A1A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Color(0xFF00FF94)),
              const SizedBox(width: 12),
              Text('Resultados', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white24, height: 32),
          
          if (_selectedMode == 0) ...[
             // Mode 1
             _buildResultRow('Base imponible (sin ITBMS)', _baseAmount),
             _buildResultRow('ITBMS (Tasa ${_rateController.text}%)', _taxAmount, isHighlight: true),
             const Divider(color: Colors.white10),
             _buildResultRow('Total a cobrar', _totalAmount, isTotal: true),
          ] else ...[
             // Mode 2
             _buildResultRow('Total con ITBMS incluido', _totalAmount, isTotal: true),
             const Divider(color: Colors.white10),
             _buildResultRow('Base imponible (sin ITBMS)', _baseAmount),
             _buildResultRow('ITBMS (Tasa ${_rateController.text}%)', _taxAmount, isHighlight: true),
          ],

          const SizedBox(height: 16),
          Text(
            '↳ Calculado usando una tasa de ITBMS de ${_rateController.text}%.',
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double amount, {bool isTotal = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isTotal ? Colors.white : (isHighlight ? const Color(0xFF00FF94) : Colors.white70),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            'B/. ${amount.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: isTotal ? const Color(0xFFF4D35E) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 20 : 16,
            ),
          ),
        ],
      ),
    );
  }


}
