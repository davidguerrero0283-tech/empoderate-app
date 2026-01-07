import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../components/premium_scaffold.dart';
import '../../components/how_to_use_card.dart';
import '../../services/worker_service.dart';
import '../../calculators/salario_models.dart';
import '../../features/payroll/domain/payroll_record.dart';

/// Dedicated screen to view all saved payroll records across all employees
class PayrollHistoryScreen extends StatefulWidget {
  const PayrollHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PayrollHistoryScreen> createState() => _PayrollHistoryScreenState();
}

class _PayrollHistoryScreenState extends State<PayrollHistoryScreen> {
  final WorkerService _service = WorkerService();
  List<WorkerProfile> _workers = [];
  List<_HistoryItem> _allRecords = [];
  bool _isLoading = true;
  String _filterEmployeeId = 'all';
  int _filterYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final workers = await _service.getWorkers();
      final List<_HistoryItem> records = [];
      
      for (final worker in workers) {
        for (final record in worker.payrollHistory) {
          records.add(_HistoryItem(worker: worker, record: record));
        }
      }
      
      records.sort((a, b) => b.record.createdAt.compareTo(a.record.createdAt));
      
      if (mounted) {
        setState(() {
          _workers = workers;
          _allRecords = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_HistoryItem> get _filteredRecords {
    return _allRecords.where((item) {
      if (_filterEmployeeId != 'all' && item.worker.id != _filterEmployeeId) {
        return false;
      }
      if (item.record.createdAt.year != _filterYear) {
        return false;
      }
      return true;
    }).toList();
  }

  double get _totalFiltered {
    return _filteredRecords.fold(0, (sum, item) => sum + item.record.netSalary);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Historial de Planillas',
      showBranding: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HowToUseCard(
                    title: '¿Qué es el Historial de Planillas?',
                    icon: Icons.history,
                    accentColor: Color(0xFF00E5FF),
                    steps: [
                      'Aquí puedes ver todas las planillas guardadas.',
                      'Filtra por empleado y año.',
                      'Toca una planilla para ver detalles.',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCards(),
                  const SizedBox(height: 20),
                  _buildFilters(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Planillas', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${_filteredRecords.length}', style: GoogleFonts.outfit(color: const Color(0xFF00E676), fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_filteredRecords.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredRecords.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _buildRecordCard(_filteredRecords[index]),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    final totalRecords = _allRecords.length;
    final totalAmount = _allRecords.fold<double>(0, (sum, item) => sum + item.record.netSalary);
    return Row(
      children: [
        Expanded(child: _buildStatCard('Planillas', '$totalRecords', Icons.receipt_long, const Color(0xFF00E5FF))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Total', '\$${totalAmount.toStringAsFixed(0)}', Icons.payments, const Color(0xFF00E676))),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF151C2B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtros', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterEmployeeId,
                  dropdownColor: const Color(0xFF0F1520),
                  decoration: const InputDecoration(labelText: 'Empleado', labelStyle: TextStyle(color: Colors.white54, fontSize: 12), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('Todos', style: TextStyle(color: Colors.white))),
                    ..._workers.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (v) => setState(() => _filterEmployeeId = v ?? 'all'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<int>(
                  value: _filterYear,
                  dropdownColor: const Color(0xFF0F1520),
                  decoration: const InputDecoration(labelText: 'Año', labelStyle: TextStyle(color: Colors.white54, fontSize: 12), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: [for (int y = DateTime.now().year; y >= DateTime.now().year - 3; y--) DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(color: Colors.white)))],
                  onChanged: (v) => setState(() => _filterYear = v ?? DateTime.now().year),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF4D35E).withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFF4D35E).withOpacity(0.3))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Filtrado:', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                Text('\$${_totalFiltered.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: const Color(0xFFF4D35E), fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(_HistoryItem item) {
    return InkWell(
      onTap: () => _showDetail(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF151C2B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: const Color(0xFF00E5FF).withOpacity(0.15), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(_getInitials(item.worker.name), style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.worker.name, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(item.record.periodLabel, style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontSize: 12)),
                  Text(DateFormat('dd/MM/yyyy').format(item.record.createdAt), style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${item.record.netSalary.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: const Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Neto', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text('No hay planillas guardadas', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Guarda planillas desde la Calculadora de Salario.', textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  void _showDetail(_HistoryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF001225),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(color: const Color(0xFF00E5FF).withOpacity(0.15), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(_getInitials(item.worker.name), style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.worker.name, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(item.record.periodLabel, style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildRow('Fecha', DateFormat('dd/MM/yyyy HH:mm').format(item.record.createdAt)),
              _buildRow('Cargo', item.worker.position),
              const Divider(color: Colors.white24, height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF00E676).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('NETO PAGADO', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold)),
                    Text('\$${item.record.netSalary.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: const Color(0xFF00E676), fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

class _HistoryItem {
  final WorkerProfile worker;
  final PayrollRecord record;
  _HistoryItem({required this.worker, required this.record});
}
