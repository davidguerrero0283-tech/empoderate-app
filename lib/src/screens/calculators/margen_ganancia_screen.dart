import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/widgets/feature_intro_screen.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../components/calculator_info_panel.dart';

class MargenGananciaScreen extends StatefulWidget {
  const MargenGananciaScreen({Key? key}) : super(key: key);

  @override
  State<MargenGananciaScreen> createState() => _MargenGananciaScreenState();
}

class _MargenGananciaScreenState extends State<MargenGananciaScreen> {
  bool _showIntro = true;
  
  // 0: Calcular precio de venta según margen deseado
  // 1: Calcular margen real según precio de venta
  int _selectedMode = 0;

  // Controllers
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _gastosController = TextEditingController();
  final TextEditingController _margenController = TextEditingController(); // for mode 0
  final TextEditingController _precioVentaController = TextEditingController(); // for mode 1

  // Results
  double _costoTotal = 0.0;
  double _precioVenta = 0.0;
  double _margen = 0.0; // percentage
  double _markup = 0.0; // percentage
  double _ganancia = 0.0;
  bool _hasCalculated = false;

  @override
  void dispose() {
    _costoController.dispose();
    _gastosController.dispose();
    _margenController.dispose();
    _precioVentaController.dispose();
    super.dispose();
  }

  void _calculate() {
    double costo = double.tryParse(_costoController.text) ?? 0.0;
    double gastos = double.tryParse(_gastosController.text) ?? 0.0;
    double total = costo + gastos;
    if (_selectedMode == 0) {
      // calculate price based on desired margin
      double margenPct = double.tryParse(_margenController.text) ?? 0.0;
      if (margenPct >= 100) {
        // avoid division by zero or negative price
        setState(() {
          _hasCalculated = false;
        });
        return;
      }
      double precio = total / (1 - margenPct / 100.0);
      double ganancia = precio - total;
      double markup = (ganancia / total) * 100.0;
      setState(() {
        _costoTotal = total;
        _precioVenta = precio;
        _margen = margenPct;
        _ganancia = ganancia;
        _markup = markup;
        _hasCalculated = true;
      });
    } else {
      // calculate margin based on given selling price
      double precio = double.tryParse(_precioVentaController.text) ?? 0.0;
      if (precio == 0) {
        setState(() { _hasCalculated = false; });
        return;
      }
      double ganancia = precio - total;
      double margenPct = (ganancia / precio) * 100.0;
      double markup = (ganancia / total) * 100.0;
      setState(() {
        _costoTotal = total;
        _precioVenta = precio;
        _margen = margenPct;
        _ganancia = ganancia;
        _markup = markup;
        _hasCalculated = true;
      });
    }
  }

  void _clearFields() {
    setState(() {
      _costoController.clear();
      _gastosController.clear();
      _margenController.clear();
      _precioVentaController.clear();
      _hasCalculated = false;
    });
  }

  // Helper to format numbers to 2 decimals
  String _fmt(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Calculadora de Margen de Ganancia',
      useScroll: false,
      usePadding: false,
      body: Stack(
        children: [
          // MAIN CONTENT - wrapped in Positioned.fill
          Positioned.fill(
            child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildModeSelector(),
                const SizedBox(height: 12),
                _buildModeExplanation(),
                const SizedBox(height: 12),
                NeonWideCard(
                  borderColor: const Color(0xFF00C9FF),
                  backgroundColor: const Color(0xFF0D1F24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cost input
                      Text('Costo del producto', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      NeonInput(
                        label: 'Costo',
                        controller: _costoController,
                        hint: 'Ej: 10.00',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 8),
                      // Additional expenses
                      Text('Gastos adicionales (opcional)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      NeonInput(
                        label: 'Gastos',
                        controller: _gastosController,
                        hint: 'Ej: 1.50',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 12),
                      // Conditional fields based on mode
                      if (_selectedMode == 0) ...[
                        Text('Margen deseado (%)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        NeonInput(
                          label: 'Margen',
                          controller: _margenController,
                          hint: 'Ej: 30',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ] else ...[
                        Text('Precio de venta', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        NeonInput(
                          label: 'Precio',
                          controller: _precioVentaController,
                          hint: 'Ej: 15.00',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: NeonButton(
                              text: _selectedMode == 0 ? 'Calcular precio' : 'Calcular margen',
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
                if (_hasCalculated) _buildResultsCard(),
                const SizedBox(height: 32),
                const CalculatorInfoPanel(configId: 'margin'),
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
                title: 'MARGEN DE GANANCIA',
                subTitle: 'Define el precio de venta que te deje ganancia real, no solo sobrevivencia.',
                heroEmoji: '💰',
                primaryColor: const Color(0xFF4DB6AC), // Teal
                features: const [
                  IntroFeatureItem(Icons.attach_money, 'Precio'),
                  IntroFeatureItem(Icons.percent, 'Margen'),
                  IntroFeatureItem(Icons.trending_up, 'Markup'),
                ],
                processSteps: const [
                  IntroStepItem('1. Costo', 'Ingresa el costo del producto.'),
                  IntroStepItem('2. Gastos', 'Agrega gastos adicionales.'),
                  IntroStepItem('3. Calcula', 'Obtén el precio o margen.'),
                ],
                proTip: 'Margen es sobre el precio de venta, Markup es sobre el costo. ¡No los confundas!',
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
          _buildModeOption(0, 'Calcular precio'),
          _buildModeOption(1, 'Calcular margen'),
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
            _hasCalculated = false;
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

  Widget _buildModeExplanation() {
    if (_selectedMode == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Modo: Calcular precio de venta', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Ingrese costo, gastos y margen deseado para obtener el precio de venta recomendado.', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Modo: Calcular margen real', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Ingrese costo, gastos y precio de venta para obtener el margen real y el markup.', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
        ],
      );
    }
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
          _buildResultRow('Costo total (incl. gastos)', _costoTotal),
          _buildResultRow('Precio de venta', _precioVenta),
          _buildResultRow('Margen (%)', _margen, isHighlight: true),
          _buildResultRow('Markup (%)', _markup, isHighlight: true),
          _buildResultRow('Ganancia por unidad', _ganancia, isTotal: true),
          const SizedBox(height: 12),
          Text(
            _selectedMode == 0
                ? '↳ Calculado con un margen deseado de ${_margen.toStringAsFixed(2)}% sobre un costo total de B/.${_fmt(_costoTotal)}.'
                : '↳ Su margen real es del ${_margen.toStringAsFixed(2)}% y su markup es del ${_markup.toStringAsFixed(2)}%.'
            ,
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
            'B/. ${_fmt(amount)}',
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
