import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../components/calculator_info_panel.dart';
import '../../calculators/salario_models.dart';
import '../../calculators/salario_logic.dart';
import '../../services/worker_service.dart';

class SalarioScreen extends StatefulWidget {
  final String? initialWorkerId;
  const SalarioScreen({Key? key, this.initialWorkerId}) : super(key: key);

  @override
  _SalarioScreenState createState() => _SalarioScreenState();
}

class _SalarioScreenState extends State<SalarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final SalarioInputModel _input = SalarioInputModel();
  SalarioResultModel? _result;
  bool _isLoading = false;

  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _salaryCtrl;
  
  // Persistence
  List<WorkerProfile> _workers = [];
  String? _selectedWorkerId;
  final WorkerService _workerService = WorkerService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _salaryCtrl = TextEditingController();
    _loadWorkers();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _salaryCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkers() async {
    final list = await _workerService.getWorkers();
    if (mounted) {
      setState(() => _workers = list);
    }
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final result = SalarioLogic.calculate(_input);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en cálculo: $e')),
      );
    }
  }

  void _reset() {
    setState(() {
      _input.workerName = '';
      _input.baseSalary = 0;
      _input.commissions = 0;
      _input.bonuses = 0;
      _nameCtrl.clear();
      _salaryCtrl.clear();
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'CALCULADORA DE SALARIO',
      subtitle: 'Planilla y Nómina',
      showBackButton: true,
      useScroll: false,
      usePadding: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool useTwoColumns = constraints.maxWidth > 900;
          
          return SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: useTwoColumns
                ? _buildTwoColumnLayout()
                : _buildSingleColumnLayout(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTwoColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildInputsColumn(),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _buildResultsColumn(),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout() {
    return Column(
      children: [
        _buildInputsColumn(),
        const SizedBox(height: 24),
        _buildResultsColumn(),
      ],
    );
  }

  Widget _buildInputsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CalculatorInfoPanel(configId: 'planilla'),
        const SizedBox(height: 16),

        // Basic Data Section
        NeonCard(
          borderColor: kNeonGreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Datos Básicos',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              NeonInput(
                label: 'Nombre del Empleado',
                controller: _nameCtrl,
                onChanged: (v) => _input.workerName = v,
              ),
              const SizedBox(height: 12),
              NeonInput(
                label: 'Salario Base Mensual (\$)',
                controller: _salaryCtrl,
                isNumber: true,
                onChanged: (v) => _input.baseSalary = double.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 12),
              NeonDropdown<PayrollFrequency>(
                label: 'Frecuencia de Pago',
                value: _input.frequency,
                items: PayrollFrequency.values.map((freq) {
                  String label;
                  if (freq == PayrollFrequency.quincenal) label = 'Quincenal';
                  else if (freq == PayrollFrequency.semanal) label = 'Semanal';
                  else label = 'Mensual';
                  return DropdownMenuItem(
                    value: freq,
                    child: Text(label, style: GoogleFonts.outfit(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _input.frequency = v ?? PayrollFrequency.quincenal),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Additional Income Section
        NeonCard(
          borderColor: kNeonBlue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingresos Adicionales (Opcional)',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              NeonInput(
                label: 'Comisiones (\$)',
                isNumber: true,
                onChanged: (v) => _input.commissions = double.tryParse(v) ?? 0,
                initialValue: _input.commissions > 0 ? _input.commissions.toString() : '',
              ),
              const SizedBox(height: 12),
              NeonInput(
                label: 'Bonificaciones (\$)',
                isNumber: true,
                onChanged: (v) => _input.bonuses = double.tryParse(v) ?? 0,
                initialValue: _input.bonuses > 0 ? _input.bonuses.toString() : '',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: NeonButton(
                text: 'Limpiar',
                onTap: _reset,
                color: Colors.white10,
                textColor: Colors.white70,
                icon: Icons.refresh,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NeonButton(
                text: 'CALCULAR',
                onTap: _calculate,
                color: kNeonCyan,
                textColor: Colors.white,
                icon: Icons.calculate,
                isLoading: _isLoading,
                primary: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildResultsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_result != null) ...[
          NeonCard(
            borderColor: kNeonGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resultado de Planilla',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildResultRow('Salario Base', _result!.baseIncome),
                if (_result!.commissionsAmount > 0)
                  _buildResultRow('Comisiones', _result!.commissionsAmount),
                if (_result!.bonusesAmount > 0)
                  _buildResultRow('Bonificaciones', _result!.bonusesAmount),
                const Divider(color: Colors.white24, height: 24),
                _buildResultRow('Total Devengado', _result!.totalDevengado, 
                  isBold: true, color: Colors.greenAccent),
                const SizedBox(height: 16),
                Text(
                  'DEDUCCIONES',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildResultRow('Seguro Social (9.75%)', _result!.css, isNegative: true),
                _buildResultRow('Seguro Educativo (1.25%)', _result!.se, isNegative: true),
                if (_result!.isr > 0)
                  _buildResultRow('ISR', _result!.isr, isNegative: true),
                const Divider(color: Colors.white24, height: 24),
                _buildResultRow('SALARIO NETO', _result!.netSalary, 
                  isBold: true, color: kNeonCyan, fontSize: 22),
              ],
            ),
          ),
        ],
        if (_result == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(64.0),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.white24),
                  const SizedBox(height: 24),
                  Text(
                    'Resultados aparecerán aquí',
                    style: GoogleFonts.outfit(
                      color: Colors.white38,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Completa los datos y presiona calcular',
                    style: GoogleFonts.outfit(
                      color: Colors.white24,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultRow(String label, double amount, {
    bool isBold = false,
    bool isNegative = false,
    Color? color,
    double fontSize = 16,
  }) {
    final displayAmount = isNegative ? -amount : amount;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: color ?? Colors.white70,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize - 2,
              ),
            ),
          ),
          Text(
            '\$${displayAmount.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: color ?? (isNegative ? Colors.redAccent : Colors.white),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
