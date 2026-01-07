import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../services/worker_service.dart';
import '../../calculators/salario_models.dart';
import '../../features/payroll/domain/payroll_record.dart';

class PeriodComparisonScreen extends StatefulWidget {
  static const routeName = '/period_comparison';

  const PeriodComparisonScreen({Key? key}) : super(key: key);

  @override
  State<PeriodComparisonScreen> createState() => _PeriodComparisonScreenState();
}

class _PeriodComparisonScreenState extends State<PeriodComparisonScreen> {
  final WorkerService _workerService = WorkerService();
  
  List<WorkerProfile> _workers = [];
  String? _selectedWorkerId;
  WorkerProfile? get _selectedWorker => _selectedWorkerId == null ? null : _workers.firstWhere((w) => w.id == _selectedWorkerId);
  
  String? _periodAId;
  String? _periodBId;
  
  PayrollRecord? get _periodA => _selectedWorker?.payrollHistory.firstWhere((p) => p.id == _periodAId, orElse: () => _selectedWorker!.payrollHistory.first);
  PayrollRecord? get _periodB => _selectedWorker?.payrollHistory.firstWhere((p) => p.id == _periodBId, orElse: () => _selectedWorker!.payrollHistory.last);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final workers = await _workerService.getWorkers();
    
    if (mounted) {
      setState(() {
        _workers = workers;
        _isLoading = false;
        
        // Auto select first worker if available
        if (_workers.isNotEmpty) {
           _selectedWorkerId = _workers.first.id;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Comparador de Periodos',
      subtitle: 'Analiza variaciones entre pagos',
      showBranding: true,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildWorkerSelector(),
                const SizedBox(height: 24),
                if (_selectedWorker != null) ...[
                   _buildPeriodSelectors(),
                   const SizedBox(height: 32),
                   if (_periodAId != null && _periodBId != null)
                      _buildComparisonResult(),
                ] else 
                   _buildEmptyWorkerState(),
                   
                const SizedBox(height: 80),
              ],
            ),
          ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kNeonBlue.withOpacity(0.1), kNeonPurple.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.compare_arrows, color: kNeonCyan, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comparación de Nómina',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Selecciona dos periodos para ver las diferencias en ingresos y deducciones.',
                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('1. SELECCIONAR COLABORADOR', style: GoogleFonts.outfit(color: kNeonGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedWorkerId,
          dropdownColor: const Color(0xFF1A2332),
          decoration: InputDecoration(
            labelText: 'Colaborador',
            filled: true,
            fillColor: const Color(0xFF151C2B),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: _workers.map((w) => DropdownMenuItem(
            value: w.id,
            child: Text(w.name, style: GoogleFonts.outfit(color: Colors.white)),
          )).toList(),
          onChanged: (v) {
            setState(() {
              _selectedWorkerId = v;
              _periodAId = null;
              _periodBId = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPeriodSelectors() {
    final history = _selectedWorker!.payrollHistory;
    
    if (history.length < 2) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
             const Icon(Icons.warning_amber, color: Colors.orange),
             const SizedBox(width: 12),
             Expanded(child: Text('Este colaborador necesita al menos 2 periodos registrados para comparar.', style: GoogleFonts.outfit(color: Colors.orangeAccent))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('2. COMPARAR PERIODOS', style: GoogleFonts.outfit(color: kNeonGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Periodo A (Base)', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _periodAId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A2332),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF151C2B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kNeonPurple.withOpacity(0.5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kNeonPurple.withOpacity(0.5))),
                    ),
                    hint: Text('Seleccionar', style: GoogleFonts.outfit(color: Colors.white38)),
                    items: history.map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.periodLabel, style: GoogleFonts.outfit(color: Colors.white), overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) => setState(() => _periodAId = v),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.only(top: 24),
              child: const Icon(Icons.arrow_forward, color: Colors.white24),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Periodo B (Comparar)', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                   const SizedBox(height: 8),
                   DropdownButtonFormField<String>(
                    value: _periodBId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A2332),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF151C2B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kNeonCyan.withOpacity(0.5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kNeonCyan.withOpacity(0.5))),
                    ),
                    hint: Text('Seleccionar', style: GoogleFonts.outfit(color: Colors.white38)),
                    items: history.map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.periodLabel, style: GoogleFonts.outfit(color: Colors.white), overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) => setState(() => _periodBId = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonResult() {
    // Find the actual record objects
    final recA = _selectedWorker!.payrollHistory.firstWhere((p) => p.id == _periodAId);
    final recB = _selectedWorker!.payrollHistory.firstWhere((p) => p.id == _periodBId);

    // Calculate diffs
    final diffGross = recB.grossSalary - recA.grossSalary;
    final diffNet = recB.netSalary - recA.netSalary;
    final diffDed = recB.totalDeducciones - recA.totalDeducciones;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Divider(color: Colors.white12),
         const SizedBox(height: 24),
         
         // MAIN KPI CARDS
         Row(
           children: [
             Expanded(child: _buildDiffCard('NÓMINA BRUTA', recA.grossSalary, recB.grossSalary, diffGross)),
             const SizedBox(width: 12),
             Expanded(child: _buildDiffCard('SALARIO NETO', recA.netSalary, recB.netSalary, diffNet, isMain: true)),
           ],
         ),
         
         const SizedBox(height: 16),
         
         // DEDUCTIONS CARD
         _buildDeductionsComparison(recA, recB),
      ],
    );
  }

  Widget _buildDiffCard(String title, double valA, double valB, double diff, {bool isMain = false}) {
    final isPositive = diff > 0;
    final isNegative = diff < 0;
    final isZero = diff == 0;
    
    // For Income: Positive diff is Good (Green)
    // Actually simpler: Just show Green for +, Red for - generally for visual logic
    
    Color diffColor = isZero ? Colors.white38 : (isPositive ? kNeonGreen : Colors.redAccent);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMain ? kNeonGreen.withOpacity(0.05) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMain ? kNeonGreen.withOpacity(0.3) : Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('A: \$${valA.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
              Text('B: \$${valB.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: diffColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isZero ? Icons.remove : (isPositive ? Icons.arrow_upward : Icons.arrow_downward),
                  color: diffColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isZero ? '-' : '\$${diff.abs().toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(color: diffColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeductionsComparison(PayrollRecord recA, PayrollRecord recB) {
     final dedA = recA.resultSnapshot['deductionsTotal'] as double? ?? recA.totalDeducciones;
     final dedB = recB.resultSnapshot['deductionsTotal'] as double? ?? recB.totalDeducciones;
     final diff = dedB - dedA;
     
     return Container(
       width: double.infinity,
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: Colors.black26,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: Colors.white10),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text('TOTAL DEDUCCIONES', style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                 Text(
                   '${diff > 0 ? '+' : ''}\$${diff.toStringAsFixed(2)}', 
                   style: GoogleFonts.outfit(color: diff > 0 ? Colors.redAccent : (diff < 0 ? kNeonGreen : Colors.white38), fontWeight: FontWeight.bold)
                 ),
              ],
            ),
            const SizedBox(height: 12),
            _row('Seguro Social', recA.resultSnapshot['css'] ?? 0, recB.resultSnapshot['css'] ?? 0),
            _row('Seguro Educativo', recA.resultSnapshot['se'] ?? 0, recB.resultSnapshot['se'] ?? 0),
            _row('ISR', recA.resultSnapshot['isr'] ?? 0, recB.resultSnapshot['isr'] ?? 0),
         ],
       ),
     );
  }
  
  Widget _row(String label, double valA, double valB) {
    if (valA == 0 && valB == 0) return const SizedBox.shrink();
    final diff = valB - valA;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12))),
          Text('\$${valA.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_right, color: Colors.white24, size: 16),
          const SizedBox(width: 8),
          Text('\$${valB.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
          const SizedBox(width: 12),
          Text(
            '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(2)}', 
            style: GoogleFonts.outfit(
              color: diff == 0 ? Colors.white24 : (diff > 0 ? Colors.redAccent : kNeonGreen),
              fontSize: 10,
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWorkerState() {
    return Center(
      child: Column(
        children: [
           Icon(Icons.person_search, size: 48, color: Colors.white.withOpacity(0.2)),
           const SizedBox(height: 16),
           Text('Selecciona un colaborador para empezar', style: GoogleFonts.outfit(color: Colors.white54)),
        ],
      ),
    );
  }
}
