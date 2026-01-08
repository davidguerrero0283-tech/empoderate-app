import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import '../../../components/premium_scaffold.dart';
import '../../../components/calculator_info_panel.dart';

// Note: Reusing generic NeonWidgets if available, otherwise creating local styles.

class CashFlowScreen extends StatefulWidget {
  const CashFlowScreen({Key? key}) : super(key: key);

  @override
  State<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends State<CashFlowScreen> {
  // Inputs
  final TextEditingController _incomeCtrl = TextEditingController();
  final TextEditingController _receivablesCtrl = TextEditingController();
  final TextEditingController _fixedExpensesCtrl = TextEditingController();
  final TextEditingController _variableExpensesCtrl = TextEditingController();

  double _finalBalance = 0.0;
  String _liquidityStatus = 'NEUTRAL'; // NEUTRAL, GOOD, WARNING, DANGER

  void _calculate() {
    final double income = double.tryParse(_incomeCtrl.text) ?? 0.0;
    final double receivables = double.tryParse(_receivablesCtrl.text) ?? 0.0;
    final double fixed = double.tryParse(_fixedExpensesCtrl.text) ?? 0.0;
    final double variable = double.tryParse(_variableExpensesCtrl.text) ?? 0.0;

    // Cash Flow = (Real Cash In) - (Real Cash Out)
    // Note: Receivables are NOT cash yet, so we exclude them from the "Cash Now" balance but show them as potential.
    // However, basic cash flow usu. tracks actual movement. 
    // Let's assume Income = Venta Total, and we might need to subtract receivables if the user entered "Ventas Totales".
    // For simplicity: Inputs are "Dinero que ENTRÓ" vs "Dinero que SALIÓ".
    // Let's adjust labels to be clear.
    
    final double totalOut = fixed + variable;
    // We treat 'receivables' as money expected but NOT in bank.
    // So Cash Flow = Income (Real) - Total Out.
    
    final double balance = income - totalOut;

    setState(() {
      _finalBalance = balance;
      if (balance > totalOut * 0.2) {
        _liquidityStatus = 'GOOD'; // >20% margin
      } else if (balance >= 0) {
         _liquidityStatus = 'WARNING'; // Positive but tight
      } else {
        _liquidityStatus = 'DANGER'; // Negative
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Flujo de Caja',
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
                // --- INFO CARD ---
                const CalculatorInfoPanel(configId: 'cash_flow'),
                const SizedBox(height: 24),

                // --- INPUTS ---
                _buildSectionTitle('Ingresos (Dinero Real)'),
                _buildNeonInput(
                  controller: _incomeCtrl,
                  label: 'Ventas Cobradas (Efectivo/Banco)',
                  icon: Icons.attach_money,
                  hint: '0.00',
                ),
                const SizedBox(height: 12),
                _buildNeonInput(
                  controller: _receivablesCtrl,
                  label: 'Cuentas por Cobrar (Fiado/Crédito)',
                  icon: Icons.pending_actions,
                  hint: '0.00',
                  isSecondary: true,
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Egresos (Salidas)'),
                 _buildNeonInput(
                  controller: _fixedExpensesCtrl,
                  label: 'Gastos Fijos (Alquiler, Salarios)',
                  icon: Icons.store,
                  hint: '0.00',
                ),
                 const SizedBox(height: 12),
                 _buildNeonInput(
                  controller: _variableExpensesCtrl,
                  label: 'Gastos Variables (Insumos, Proveedores)',
                  icon: Icons.shopping_cart,
                  hint: '0.00',
                ),

                const SizedBox(height: 32),

                // --- CALCULATE BUTTON ---
                ElevatedButton(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DD0E1).withOpacity(0.2),
                    foregroundColor: const Color(0xFF4DD0E1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF4DD0E1), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'CALCULAR LIQUIDEZ',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),

                const SizedBox(height: 32),

                // --- RESULTS (TRAFFIC LIGHT) ---
                if (_liquidityStatus != 'NEUTRAL')
                  _buildResultCard(),

                ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
         title,
         style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, textBaseline: TextBaseline.alphabetic),
      ),
    );
  }

  Widget _buildNeonInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isSecondary = false,
  }) {
    final color = isSecondary ? Colors.orangeAccent : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: isSecondary ? Colors.orangeAccent.withOpacity(0.8) : Colors.white54),
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.white24),
          prefixIcon: Icon(icon, color: isSecondary ? Colors.orangeAccent : Colors.white54, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    Color statusColor;
    String statusTitle;
    String statusMsg;
    IconData statusIcon;

    switch (_liquidityStatus) {
      case 'GOOD':
        statusColor = const Color(0xFFAED581); // Green
        statusTitle = 'LIQUIDEZ SANA';
        statusMsg = '¡Excelente! Tienes suficiente efectivo para cubrir tus operaciones y margen para imprevistos.';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'WARNING':
        statusColor = const Color(0xFFFFD54F); // Yellow
        statusTitle = 'PRECAUCIÓN';
        statusMsg = 'Cubres tus gastos pero quedas justo. Vigila tus gastos variables o intenta cobrar las cuentas pendientes.';
        statusIcon = Icons.warning_amber_rounded;
        break;
      case 'DANGER':
      default:
        statusColor = const Color(0xFFE57373); // Red
        statusTitle = 'PELIGRO DE ILIQUIDEZ';
        statusMsg = 'Tus salidas superan tus entradas de efectivo. Necesitas inyectar capital, diferir pagos o cobrar urgente.';
        statusIcon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: statusColor.withOpacity(0.05), blurRadius: 30, spreadRadius: 0),
        ],
      ),
      child: Column(
        children: [
          Icon(statusIcon, color: statusColor, size: 48),
          const SizedBox(height: 16),
          Text(
            '\$${_finalBalance.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: statusColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Saldo Final de Caja',
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12, letterSpacing: 1.0),
          ),
          const SizedBox(height: 24),
          Text(
            statusTitle,
            style: GoogleFonts.outfit(color: statusColor, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            statusMsg,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          
          if (_receivablesCtrl.text.isNotEmpty && (double.tryParse(_receivablesCtrl.text) ?? 0) > 0) ...[
             const SizedBox(height: 24),
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.lightbulb, color: Colors.orangeAccent, size: 16),
                   const SizedBox(width: 8),
                   Flexible(
                     child: Text(
                       'Tip: Tienes \$${_receivablesCtrl.text} por cobrar. ¡Recupéralos!',
                       style: GoogleFonts.outfit(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold),
                     ),
                   ),
                 ],
               ),
             )
          ]
        ],
      ),
    );
  }
}
