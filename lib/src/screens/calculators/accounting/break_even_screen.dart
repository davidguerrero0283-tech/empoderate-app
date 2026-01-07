import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import '../../../components/premium_scaffold.dart';
import '../../../components/calculator_info_panel.dart';

class BreakEvenScreen extends StatefulWidget {
  const BreakEvenScreen({Key? key}) : super(key: key);

  @override
  State<BreakEvenScreen> createState() => _BreakEvenScreenState();
}

class _BreakEvenScreenState extends State<BreakEvenScreen> {
  final TextEditingController _fixedCostsCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _variableCostCtrl = TextEditingController();

  double _breakEvenUnits = 0.0;
  double _breakEvenSales = 0.0;
  bool _calculated = false;

  void _calculate() {
    final double fixed = double.tryParse(_fixedCostsCtrl.text) ?? 0.0;
    final double price = double.tryParse(_priceCtrl.text) ?? 0.0;
    final double variable = double.tryParse(_variableCostCtrl.text) ?? 0.0;

    if (price <= variable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El precio debe ser mayor al costo variable.')),
      );
      return;
    }

    final double margin = price - variable;
    final double units = fixed / margin;
    final double sales = units * price;

    setState(() {
      _breakEvenUnits = units;
      _breakEvenSales = sales;
      _calculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Punto de Equilibrio',
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- INFO CARD ---
            const CalculatorInfoPanel(configId: 'break_even_acc'),
            const SizedBox(height: 24),

            // --- INPUTS ---
            _buildSectionTitle('Costos del Negocio'),
            _buildNeonInput(controller: _fixedCostsCtrl, label: 'Costos Fijos Totales (Mes)', icon: Icons.store, hint: 'Ej: 1500.00'),
            const SizedBox(height: 12),
            _buildSectionTitle('Datos del Producto/Servicio Promedio'),
            Row(
              children: [
                Expanded(child: _buildNeonInput(controller: _priceCtrl, label: 'Precio Venta', icon: Icons.sell, hint: 'Ej: 10.00')),
                const SizedBox(width: 12),
                Expanded(child: _buildNeonInput(controller: _variableCostCtrl, label: 'Costo Variable', icon: Icons.shopping_bag, hint: 'Ej: 4.50')),
              ],
            ),

            const SizedBox(height: 32),

            // --- ACTION ---
            ElevatedButton(
              onPressed: _calculate,
              style: _actionButtonStyle(),
              child: Text('CALCULAR MI META', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),

            const SizedBox(height: 32),

            // --- RESULTS ---
            if (_calculated)
               _buildMagicNumberCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

   ButtonStyle _actionButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFBA68C8).withOpacity(0.2), // Purple
      foregroundColor: const Color(0xFFBA68C8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      side: const BorderSide(color: Color(0xFFBA68C8), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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

  Widget _buildMagicNumberCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFBA68C8).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBA68C8).withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFFBA68C8).withOpacity(0.05), blurRadius: 30)],
      ),
      child: Column(
        children: [
          Text('TU NÚMERO MÁGICO', style: GoogleFonts.outfit(color: const Color(0xFFBA68C8), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_breakEvenUnits.ceil().toString(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 8),
                child: Text('unidades/mes', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Necesitas vender \$${_breakEvenSales.toStringAsFixed(2)} para no perder dinero.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white10),
          const SizedBox(height: 12),
          // Daily Target
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniTarget('15 Días', (_breakEvenUnits / 15).ceil()),
              _buildMiniTarget('20 Días', (_breakEvenUnits / 20).ceil()),
              _buildMiniTarget('25 Días', (_breakEvenUnits / 25).ceil()),
            ],
          ),
           const SizedBox(height: 12),
           Text(
            '(Meta diaria según días que abras)',
            style: GoogleFonts.outfit(color: Colors.white30, fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTarget(String label, int amount) {
    return Column(
      children: [
        Text(amount.toString(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
