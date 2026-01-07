import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/features/marketing/marketing_service.dart';

class MarketingFunnelScreen extends StatefulWidget {
  const MarketingFunnelScreen({Key? key}) : super(key: key);

  @override
  State<MarketingFunnelScreen> createState() => _MarketingFunnelScreenState();
}

class _MarketingFunnelScreenState extends State<MarketingFunnelScreen> {
  final MarketingService _service = MarketingService();
  
  // Filters
  String _range = '30d';
  String _channel = 'Todos';
  
  // Simulation Mode
  bool _isSimulationMode = false;
  
  // Funnel Data (State)
  double _impressions = 45200;
  double _clickRate = 8.5; // percent
  double _leadRate = 11.0; // percent of clicks
  double _saleRate = 13.8; // percent of leads
  
  // Controllers
  final _impressionsCtrl = TextEditingController();
  final _clickRateCtrl = TextEditingController();
  final _leadRateCtrl = TextEditingController();
  final _saleRateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadState();
  }
  
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _impressions = prefs.getDouble('mkt_funnel_impressions') ?? 45200;
      _clickRate = prefs.getDouble('mkt_funnel_click_rate') ?? 8.5;
      _leadRate = prefs.getDouble('mkt_funnel_lead_rate') ?? 11.0;
      _saleRate = prefs.getDouble('mkt_funnel_sale_rate') ?? 13.8;
      _isSimulationMode = prefs.getBool('mkt_funnel_simulation') ?? false;
      _updateControllers();
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('mkt_funnel_impressions', _impressions);
    await prefs.setDouble('mkt_funnel_click_rate', _clickRate);
    await prefs.setDouble('mkt_funnel_lead_rate', _leadRate);
    await prefs.setDouble('mkt_funnel_sale_rate', _saleRate);
    await prefs.setBool('mkt_funnel_simulation', _isSimulationMode);
    
    // Signal for Progress
    await prefs.setBool('marketing.funnel_configured', true);
  }

  void _updateControllers() {
    _impressionsCtrl.text = _impressions.toStringAsFixed(0);
    _clickRateCtrl.text = _clickRate.toStringAsFixed(1);
    _leadRateCtrl.text = _leadRate.toStringAsFixed(1);
    _saleRateCtrl.text = _saleRate.toStringAsFixed(1);
  }

  void _recalculateFunnel() {
    setState(() {
      _impressions = double.tryParse(_impressionsCtrl.text) ?? 0;
      _clickRate = double.tryParse(_clickRateCtrl.text) ?? 0;
      _leadRate = double.tryParse(_leadRateCtrl.text) ?? 0;
      _saleRate = double.tryParse(_saleRateCtrl.text) ?? 0;
    });
    _saveState();
  }

  @override
  Widget build(BuildContext context) {
    // Calculations
    double clicks = _impressions * (_clickRate / 100);
    double leads = clicks * (_leadRate / 100);
    double sales = leads * (_saleRate / 100);
    double globalConversion = _impressions > 0 ? (sales / _impressions) * 100 : 0.0;

    return PremiumScaffold(
      title: 'Embudo de Ventas Pro',
      isNeonTitle: true,
      showBackButton: true,
      actions: [
         IconButton(
           icon: const Icon(Icons.download, color: Colors.white54), 
           tooltip: 'Exportar Reporte',
           onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportando CSV...'))),
         )
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildFilters(),
            const SizedBox(height: 20),
            _buildExecutiveKPIs(sales),
            const SizedBox(height: 30),
            
            // Funnel Section
            _buildSimulationToggle(),
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildStage(
                    'Alcance / Impresiones', 
                    NumberFormat.decimalPattern().format(_impressions), 
                    '100%', 
                    Colors.blue, 
                    1.0, 
                    isEditable: _isSimulationMode,
                    controller: _impressionsCtrl,
                    tooltip: 'Número total de veces que tu anuncio fue visto.',
                  ),
                  _buildDropOff(_impressions, clicks),
                  _buildStage(
                    'Interacción / Clics', 
                    NumberFormat.decimalPattern().format(clicks), 
                    '${_clickRate.toStringAsFixed(1)}% CTR', 
                    Colors.purpleAccent, 
                    0.85,
                    isEditable: _isSimulationMode,
                    controller: _clickRateCtrl,
                    isRate: true,
                    tooltip: 'Usuarios que hicieron clic en tu anuncio.',
                  ),
                  _buildDropOff(clicks, leads),
                  _buildStage(
                    'Clientes Potenciales (Leads)', 
                    NumberFormat.decimalPattern().format(leads), 
                    '${_leadRate.toStringAsFixed(1)}% Conv.', 
                    Colors.orangeAccent, 
                    0.7,
                    isEditable: _isSimulationMode,
                    controller: _leadRateCtrl,
                    isRate: true,
                    tooltip: 'Usuarios que dejaron sus datos o contactaron.',
                  ),
                  _buildDropOff(leads, sales),
                  _buildStage(
                    'Ventas Cerradas', 
                    NumberFormat.decimalPattern().format(sales), 
                    '${_saleRate.toStringAsFixed(1)}% Cierre', 
                    Colors.greenAccent, 
                    0.55,
                    isEditable: _isSimulationMode,
                    controller: _saleRateCtrl,
                    isRate: true,
                    tooltip: 'Ventas efectivas realizadas.',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            NeonWideCard(
              borderColor: globalConversion > 1.0 ? Colors.greenAccent : Colors.orangeAccent,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Tasa de Conversión Global', style: GoogleFonts.outfit(color: Colors.white70)),
                    Text('${globalConversion.toStringAsFixed(2)}%', style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    if (_isSimulationMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: NeonButton(
                          text: "Guardar Escenario", 
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escenario guardado'))),
                          color: Colors.cyanAccent,
                          primary: false,
                        ),
                      )
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            const NeonSectionTitle(title: 'Tendencia (30 días)', color: Colors.blueGrey),
            const SizedBox(height: 16),
            _buildTrendChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('Rango', _range, ['7d', '30d', '90d'], (v) => setState(() => _range = v)),
          const SizedBox(width: 8),
          _buildFilterChip('Canal', _channel, ['Todos', 'Meta', 'Google', 'TikTok'], (v) => setState(() => _channel = v)),
          const SizedBox(width: 8),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
             decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(20)),
             child: const Text('Campaña: Todas', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value, List<String> options, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: Container(),
        dropdownColor: const Color(0xFF151C2B),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  Widget _buildExecutiveKPIs(double sales) {
    // Mock KPIs derived from sales/impressions
    double revenue = sales * 150.0; // Avg ticket $150
    double spend = _impressions * 0.05; // CPM approx
    double roas = spend > 0 ? revenue / spend : 0;
    
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildKPICard('Inversión', '\$${spend.toStringAsFixed(0)}', Colors.blueGrey),
          _buildKPICard('Ingresos', '\$${revenue.toStringAsFixed(0)}', Colors.greenAccent),
          _buildKPICard('ROAS', '${roas.toStringAsFixed(1)}x', Colors.purpleAccent),
          _buildKPICard('CPL', '\$4.50', Colors.orangeAccent),
          _buildKPICard('CAC', '\$35.00', Colors.redAccent),
        ],
      ),
    );
  }
  
  Widget _buildKPICard(String label, String value, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSimulationToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: _isSimulationMode ? Colors.cyanAccent : Colors.white24),
              const SizedBox(width: 8),
              Text('Modo Simulación', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          Switch(
            value: _isSimulationMode, 
            activeColor: Colors.cyanAccent,
            onChanged: (v) => setState(() => _isSimulationMode = v),
          )
        ],
      ),
    );
  }

  Widget _buildStage(
    String label, String value, String rate, Color color, double widthFactor, 
    {required bool isEditable, TextEditingController? controller, bool isRate = false, String tooltip = ''}
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Glow
        Container(
          height: 80,
          margin: const EdgeInsets.symmetric(vertical: 4),
          width: MediaQuery.of(context).size.width * widthFactor,
          decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(16),
             boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20)],
          ),
        ),
        // Content
        Container(
          width: MediaQuery.of(context).size.width * widthFactor,
          constraints: const BoxConstraints(minWidth: 280),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF151C2B).withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              // Icon & Label
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 6),
                        Tooltip(
                          message: tooltip,
                          triggerMode: TooltipTriggerMode.tap,
                          child: Icon(Icons.info_outline, size: 14, color: Colors.white24),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    isEditable && isRate
                        ? SizedBox(
                            width: 60, height: 20,
                            child: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration.collapsed(hintText: 'Rate'),
                              onSubmitted: (_) => _recalculateFunnel(),
                            ),
                          )
                        : Text(rate, style: GoogleFonts.outfit(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Value
              Expanded(
                flex: 2,
                child: isEditable && !isRate
                    ? TextField(
                        controller: controller,
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration.collapsed(hintText: 'Val'),
                        onSubmitted: (_) => _recalculateFunnel(),
                      )
                    : Text(value, textAlign: TextAlign.end, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropOff(double prev, double current) {
    if (prev == 0) return const SizedBox(height: 10);
    double dropOff = ((prev - current) / prev) * 100;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Drop-off: -${dropOff.toStringAsFixed(1)}%',
        style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  Widget _buildTrendChart() {
    final history = _service.getFunnelHistory(); // Mock data
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['leads'] as int).toDouble())).toList(),
              isCurved: true,
              color: Colors.orangeAccent,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.orangeAccent.withOpacity(0.1)),
            ),
             LineChartBarData(
              spots: history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['sales'] as int).toDouble() * 5)).toList(), // Scale up sales for visibility
              isCurved: true,
              color: Colors.greenAccent,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
