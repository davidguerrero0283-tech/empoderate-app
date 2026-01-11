import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../components/premium_scaffold.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import 'package:intl/intl.dart';
import '../../../rrhh/obligaciones/services/obligaciones_updates_service.dart';
import '../../../rrhh/obligaciones/data/obligaciones_update_models.dart';

class CssCuotaToolkitScreen extends StatefulWidget {
  const CssCuotaToolkitScreen({super.key});

  @override
  State<CssCuotaToolkitScreen> createState() => _CssCuotaToolkitScreenState();
}

class _CssCuotaToolkitScreenState extends State<CssCuotaToolkitScreen> {
  final TextEditingController _salaryController = TextEditingController();
  final ObligacionesUpdatesService _service = ObligacionesUpdatesService();
  
  ObligacionesModuleUpdate? _moduleData;
  bool _isLoading = true;
  bool _isOffline = false;
  bool _isRefreshing = false;
  
  double _employerRate = 0.1325;
  double? _resultEmpleado;
  double? _resultEmpleador;
  double? _resultTotal;

  @override
  void initState() {
    super.initState();
    _loadModule();
  }

  Future<void> _loadModule() async {
    final data = await _service.getModule('css');
    final offline = await _service.isUsingOfflineContent();
    
    // Mark as seen
    await _service.markModuleSeen('css', data.version);
    
    setState(() {
      _moduleData = data;
      _isLoading = false;
      _isOffline = offline;
      
      // Load rates from toolConfig
      final rates = data.toolConfig['employerRates'] as List<dynamic>?;
      if (rates != null && rates.isNotEmpty) {
        _employerRate = (rates.first['rate'] as num?)?.toDouble() ?? 0.1325;
      }
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await _service.forceRefresh();
    await _loadModule();
    setState(() => _isRefreshing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Contenido actualizado')),
      );
    }
  }

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  void _calculate() {
    final salary = double.tryParse(_salaryController.text);
    if (salary == null) return;

    final employeeRate = (_moduleData?.toolConfig['employeeRate'] as num?)?.toDouble() ?? 0.0975;
    setState(() {
      _resultEmpleado = salary * employeeRate;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // VERSION HEADER
                  _buildVersionHeader(),
                  const SizedBox(height: 16),
                  
                  // OFFLINE BANNER
                  if (_isOffline) _buildOfflineBanner(),
                  
                  _buildHeaderSection(),
                  const SizedBox(height: 24),
                  
                  // SUMMARY FROM SERVICE
                  _buildSummarySection(),
                  const SizedBox(height: 24),
                  
                  _buildCalculatorSection(),
                  const SizedBox(height: 24),
                  _buildSourcesSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildVersionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: EmpoderateTheme.gold, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Versión: ${_moduleData?.version ?? 'N/A'} • Revisado: ${_moduleData?.lastReviewed ?? 'N/A'}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          _isRefreshing
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  color: EmpoderateTheme.gold,
                  onPressed: _onRefresh,
                  tooltip: 'Actualizar ahora',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: const [
          Icon(Icons.cloud_off, color: Colors.orange, size: 18),
          SizedBox(width: 8),
          Expanded(child: Text('Modo offline: usando contenido base', style: TextStyle(color: Colors.orange, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: EmpoderateTheme.gold, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen', style: GoogleFonts.outfit(color: EmpoderateTheme.gold, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Text(_moduleData?.summary ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          ...(_moduleData?.keyPoints ?? []).map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(point, style: const TextStyle(color: Colors.white60, fontSize: 12))),
              ],
            ),
          )),
        ],
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
                Text('Cuota Obrero Patronal', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Gestión de aportes a la Caja de Seguro Social (CSS) y cumplimiento de la Ley 51.', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70)),
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
              Text('Calculadora Rápida de Aportes', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
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
          child: Text(label, style: TextStyle(color: isSelected ? EmpoderateTheme.gold : Colors.white60, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double value, {bool isTotal = false}) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.white : Colors.white70, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(currencyFormat.format(value), style: GoogleFonts.outfit(color: isTotal ? EmpoderateTheme.gold : Colors.white, fontSize: isTotal ? 18 : 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSourcesSection() {
    final sources = _moduleData?.sources ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fuentes Oficiales', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...sources.map((s) => _buildLinkButton(s.title, s.url)),
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
