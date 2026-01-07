import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../components/calculator_info_panel.dart';
import '../calculators/decimo_logic.dart';
import '../calculators/decimo_models.dart';

class DecimoTercerMesScreen extends StatefulWidget {
  const DecimoTercerMesScreen({Key? key}) : super(key: key);

  @override
  _DecimoTercerMesScreenState createState() => _DecimoTercerMesScreenState();
}

class _DecimoTercerMesScreenState extends State<DecimoTercerMesScreen> {
  final _formKey = GlobalKey<FormState>();
  
  double _totalEarnings = 0.0;
  DecimoResultModel? _result;
  bool _isLoading = false;

  void _calculate() async {
    if (_totalEarnings <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingrese un monto válido.')));
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final res = DecimoLogic.calculate(_totalEarnings);
    setState(() {
      _result = res;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'DÉCIMO TERCER MES',
      showBackButton: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Calculadora de Décimo Tercer Mes',
            style: EmpoderateTheme.titleStyle.copyWith(fontSize: 18),
          ),
          const CalculatorInfoPanel(configId: 'decimo'),
          const SizedBox(height: 24),
          
          // Input Card
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('INGRESOS DEL PERIODO', style: EmpoderateTheme.titleStyle.copyWith(fontSize: 14)),
                const SizedBox(height: 12),
                NeonInput(
                  label: 'Total Ganado (Suma 4 meses) (\$)', 
                  isNumber: true, 
                  onChanged: (v) => _totalEarnings = double.tryParse(v) ?? 0
                ),
                const SizedBox(height: 16),
                NeonButton(
                  text: 'CALCULAR DÉCIMO',
                  primary: true,
                  color: const Color(0xFF3CFFB5),
                  textColor: Colors.black,
                  onTap: _calculate,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          
          if (_result != null)
            NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RESULTADO', style: EmpoderateTheme.titleStyle.copyWith(fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildRow('Base de Cálculo', _result!.totalEarnings),
                  const Divider(color: Colors.white24),
                  _buildRow('Décimo Bruto', _result!.decimoAmount, isBold: true),
                  _buildRow('Seguro Social (7.25%)', _result!.css, isNegative: true),
                  const Divider(color: Colors.white24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EmpoderateTheme.goldStrong.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: EmpoderateTheme.goldStrong),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('A RECIBIR', style: EmpoderateTheme.titleStyle.copyWith(fontSize: 18)),
                        Text('\$${_result!.netDecimo.toStringAsFixed(2)}', style: EmpoderateTheme.titleStyle.copyWith(color: Colors.white, fontSize: 22)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount, {bool isBold = false, bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          Text(
            '${isNegative ? "-" : ""}\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: isNegative ? Colors.redAccent : (isBold ? Colors.white : Colors.white),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
