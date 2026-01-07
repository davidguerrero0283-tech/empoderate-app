import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import '../../../components/premium_scaffold.dart';
import '../../../components/calculator_info_panel.dart';

class TaxEstimatorScreen extends StatefulWidget {
  const TaxEstimatorScreen({Key? key}) : super(key: key);

  @override
  State<TaxEstimatorScreen> createState() => _TaxEstimatorScreenState();
}

class _TaxEstimatorScreenState extends State<TaxEstimatorScreen> {
  final TextEditingController _incomeCtrl = TextEditingController();
  bool _isNaturalPerson = true; // Natural vs Juridica

  double _itbms = 0.0; // 7%
  double _estimatedIsr = 0.0; 
  double _educationalInsurance = 0.0;
  bool _calculated = false;

  void _calculate() {
    final double income = double.tryParse(_incomeCtrl.text) ?? 0.0;
    
    // 1. ITBMS (Assuming income is gross sales subject to tax)
    // Basic estimation: 7% of gross.
    final double itbmsVal = income * 0.07;

    // 2. Educational Insurance / Social Security (Patronal estimated)
    // This is VERY rough. Usually based on payroll, but for self-employed Natural Person, it varies.
    // Let's assume a self-employed contribution estimation roughly 13.5% of income if it was salary?
    // No, better to stick to simple business taxes.
    // For Juridical: based on dividends or net income.
    // Let's keep it simple: 
    // Seguro Educativo varies: 1.25% employee + 1.50% employer = 2.75% of payroll.
    // Let's simulate that the entrepreneur pays themselves this entire income (simplified).
    // Or just 1.25% as "Seguro Educativo Generic Estimate" to be safe.
    final double eduVal = income * 0.0125; 

    // 3. ISR (Income Tax) - VERY simplified Panama Brackets (Annual)
    // We treat input as MONTHLY for the user, but calc annually for brackets.
    final double annualIncome = income * 12;
    double annualTax = 0.0;

    if (_isNaturalPerson) {
      if (annualIncome <= 11000) {
        annualTax = 0.0;
      } else if (annualIncome <= 50000) {
        annualTax = (annualIncome - 11000) * 0.15;
      } else {
        annualTax = ((50000 - 11000) * 0.15) + ((annualIncome - 50000) * 0.25);
      }
    } else {
      // Juridical (25% Corporate Tax standard - Simplified)
      // Or CAIR. Let's stick to 25% of Net. Assuming Net is ~30% of Gross for estimation? 
      // Too complex to guess Net. Let's just calculate 25% of this specific income assuming it's taxable profit.
      // Warning needed: "Esto asume que todo el ingreso es ganancia gravable".
      annualTax = annualIncome * 0.25; 
    }

    final double monthlyTax = annualTax / 12;

    setState(() {
      _itbms = itbmsVal;
      _educationalInsurance = eduVal;
      _estimatedIsr = monthlyTax;
      _calculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Estimador de Impuestos',
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CalculatorInfoPanel(configId: 'tax_estimator'),
            const SizedBox(height: 24),

            // --- TYPE SWITCH ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
              child: Row(
                children: [
                  Expanded(child: _buildSwitchOption('Persona Natural', _isNaturalPerson)),
                  Expanded(child: _buildSwitchOption('Persona Jurídica', !_isNaturalPerson)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- INPUT ---
             _buildSectionTitle('Ingresos del Mes (Antes de Impuestos)'),
             _buildNeonInput(controller: _incomeCtrl, label: 'Facturación Bruta Mensual', icon: Icons.attach_money, hint: 'Ej: 2500.00'),
             if (!_isNaturalPerson)
               Padding(
                 padding: const EdgeInsets.only(top: 8, left: 4),
                 child: Text('*Para Jurídica, cálculo asume 25% sobre este monto (si fuera ganancia neta).', style: GoogleFonts.outfit(color: Colors.white30, fontSize: 11)),
               ),

             const SizedBox(height: 32),
             ElevatedButton(
              onPressed: _calculate,
              style: _actionButtonStyle(),
              child: Text('CALCULAR RETENCIONES', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),

            const SizedBox(height: 32),

            if (_calculated) ...[
              _buildSavingsPiggyBank(),
              const SizedBox(height: 20),
              _buildBreakdownCard(),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchOption(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isNaturalPerson = (text == 'Persona Natural');
          _calculated = false; // Reset
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE57373) : Colors.transparent, // Pink/Red for Taxes
          borderRadius: BorderRadius.circular(50),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsPiggyBank() {
    final double weeklySavings = (_itbms + _estimatedIsr) / 4;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE57373).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE57373).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.savings_outlined, color: const Color(0xFFE57373), size: 40),
          const SizedBox(height: 12),
          Text(
            'LA ALCANCÍA FISCAL',
            style: GoogleFonts.outfit(color: const Color(0xFFE57373), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Deberías separar',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
          ),
          Text(
            '\$${weeklySavings.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Text(
            'cada semana',
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Text(
            'Para no sufrir a fin de mes/año cuando toque pagar a la DGI.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildRow('ITBMS (7%)', _itbms, Colors.orangeAccent),
          Divider(color: Colors.white10),
          _buildRow('ISR Estimado (Mensual)', _estimatedIsr, Colors.lightBlueAccent),
          Divider(color: Colors.white10),
          _buildRow('Seguro Educativo', _educationalInsurance, Colors.white60),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total a Guardar (Mes)', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('\$${(_itbms + _estimatedIsr + _educationalInsurance).toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white70)),
          Text('\$${amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w600)),
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

  Widget _buildNeonInput({required TextEditingController controller, required String label, required IconData icon, required String hint}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: Colors.white54),
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.white24),
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
   ButtonStyle _actionButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE57373).withOpacity(0.2), 
      foregroundColor: const Color(0xFFE57373),
      padding: const EdgeInsets.symmetric(vertical: 16),
      side: const BorderSide(color: Color(0xFFE57373), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    );
  }
}
