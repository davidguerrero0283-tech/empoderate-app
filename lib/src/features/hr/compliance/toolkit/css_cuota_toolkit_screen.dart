import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../components/premium_scaffold.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import 'package:intl/intl.dart';

class CssCuotaToolkitScreen extends StatefulWidget {
  const CssCuotaToolkitScreen({super.key});

  @override
  State<CssCuotaToolkitScreen> createState() => _CssCuotaToolkitScreenState();
}

class _CssCuotaToolkitScreenState extends State<CssCuotaToolkitScreen> {
  final TextEditingController _salaryController = TextEditingController();
  double _employerRate = 0.1325; // 13.25% default
  String _vigencia = 'Vigente';
  double? _resultEmpleado;
  double? _resultEmpleador;
  double? _resultTotal;

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  void _calculate() {
    final salary = double.tryParse(_salaryController.text);
    if (salary == null) return;

    setState(() {
      _resultEmpleado = salary * 0.0975; // 9.75% Fixed for employee
      _resultEmpleador = salary * _employerRate;
      _resultTotal = _resultEmpleado! + _resultEmpleador!;
    });
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'CSS / Cuotas',
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildCalculatorSection(),
            const SizedBox(height: 24),
            _buildOfficialInfoSection(),
            const SizedBox(height: 24),
            _buildSourcesSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.security, size: 40, color: Color(0xFF1E88E5)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuota Obrero Patronal',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestión de aportes a la Caja de Seguro Social (CSS) y cumplimiento de la Ley 51.',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate, color: EmpoderateTheme.gold),
              const SizedBox(width: 8),
              Text(
                'Calculadora Rápida de Aportes',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Salary Input
          TextField(
            controller: _salaryController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Salario Mensual Bruto',
              labelStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.attach_money, color: Colors.white54),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 16),

          // Rate Selector
          Text('Vigencia Aporte Patronal:', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildRateOption('Actual (13.25%)', 0.1325),
              const SizedBox(width: 12),
              _buildRateOption('2027-2029 (14.25%)', 0.1425),
            ],
          ),
          const SizedBox(height: 20),

          // Results
          if (_resultEmpleado != null)
            Column(
              children: [
                _buildResultRow('Aporte Empleado (9.75%)', _resultEmpleado!),
                const SizedBox(height: 8),
                _buildResultRow('Aporte Empleador (${(_employerRate * 100).toStringAsFixed(2)}%)', _resultEmpleador!),
                const Divider(color: Colors.white24, height: 24),
                _buildResultRow('Total a Pagar a CSS', _resultTotal!, isTotal: true),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRateOption(String label, double val) {
    final isSelected = _employerRate == val;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _employerRate = val;
            _calculate();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? EmpoderateTheme.gold.withOpacity(0.2) : Colors.white10,
            border: Border.all(color: isSelected ? EmpoderateTheme.gold : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? EmpoderateTheme.gold : Colors.white60,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double value, {bool isTotal = false}) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white70, 
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal
          ),
        ),
        Text(
          currencyFormat.format(value),
          style: GoogleFonts.outfit(
            color: isTotal ? EmpoderateTheme.gold : Colors.white,
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOfficialInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Información Oficial', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.info_outline,
          title: 'Ajuste Escalonado (Ley 462)',
          content: 'El aumento de la cuota patronal es progresivo. El primer ajuste del 1% se aplica desde la cuota de abril 2025 (pagadera en mayo).',
        ),
        const SizedBox(height: 8),
        _buildInfoCard(
          icon: Icons.calendar_today,
          title: 'Plazos SIPE',
          content: 'Presentación de planilla: Hasta el día 20 del mes.\nPago: Desde la presentación hasta el último día del mes.',
        ),
      ],
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Color(0xFF1E88E5), width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fuentes Oficiales & Accesos', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildLinkButton('Acceso SIPE (CSS)', 'https://sipe.css.gob.pa/'),
        _buildLinkButton('Gaceta Oficial (Ley 462)', 'https://www.gacetaoficial.gob.pa/'),
        _buildLinkButton('Mitradel - Cálculos', 'https://www.mitradel.gob.pa/'),
      ],
    );
  }

  Widget _buildLinkButton(String text, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: const Icon(Icons.open_in_new, size: 16),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF64B5F6),
          side: const BorderSide(color: Color(0xFF64B5F6)),
          alignment: Alignment.centerLeft,
          minimumSize: const Size(double.infinity, 40),
        ),
      ),
    );
  }
}
