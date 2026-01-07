import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../components/neon_widgets.dart';
import '../../components/premium_scaffold.dart';
import '../../features/hr_archive/models/hr_central_record.dart';
import '../../features/hr_archive/services/hr_archive_service.dart';
import '../../services/worker_service.dart';
import '../../calculators/salario_models.dart';

/// Pantalla central de archivo de registros de RRHH
class HRArchiveScreen extends StatefulWidget {
  static const routeName = '/hr_archive';
  final String? initialWorkerId;
  
  const HRArchiveScreen({Key? key, this.initialWorkerId}) : super(key: key);

  @override
  State<HRArchiveScreen> createState() => _HRArchiveScreenState();
}

class _HRArchiveScreenState extends State<HRArchiveScreen> {
  final HRArchiveService _archiveService = HRArchiveService();
  final WorkerService _workerService = WorkerService();
  
  List<HRCentralRecord> _records = [];
  List<WorkerProfile> _workers = [];
  bool _isLoading = true;
  
  // Filters
  HRRecordType? _filterType;
  String _filterWorkerId = 'all';
  int _filterYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    if (widget.initialWorkerId != null) {
      _filterWorkerId = widget.initialWorkerId!;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final records = await _archiveService.getAll();
      final workers = await _workerService.getWorkers();
      
      // Also sync existing payroll records to archive if not already there
      await _syncPayrollRecords(workers);
      
      final updatedRecords = await _archiveService.getAll();
      
      if (mounted) {
        setState(() {
          _records = updatedRecords;
          _workers = workers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Sincroniza los registros de payrollHistory existentes al archivo central
  Future<void> _syncPayrollRecords(List<WorkerProfile> workers) async {
    final existing = await _archiveService.getAll();
    final existingIds = existing.map((r) => r.id).toSet();
    
    for (final worker in workers) {
      for (final payroll in worker.payrollHistory) {
        // Use payroll ID as reference
        final archiveId = 'payroll_${payroll.id}';
        if (!existingIds.contains(archiveId)) {
          await _archiveService.add(HRCentralRecord(
            id: archiveId,
            workerId: worker.id,
            workerName: worker.name,
            type: HRRecordType.planilla,
            eventDate: payroll.createdAt,
            description: payroll.periodLabel,
            amount: payroll.netSalary,
            data: {
              'periodKey': payroll.periodKey,
              'grossSalary': payroll.grossSalary,
              'totalDeducciones': payroll.totalDeducciones,
            },
          ));
        }
      }
    }
  }

  List<HRCentralRecord> get _filteredRecords {
    return _records.where((r) {
      if (_filterType != null && r.type != _filterType) return false;
      if (_filterWorkerId != 'all' && r.workerId != _filterWorkerId) return false;
      if (r.eventDate.year != _filterYear) return false;
      return true;
    }).toList();
  }

  double get _totalAmount => _filteredRecords.fold(0, (sum, r) => sum + (r.amount ?? 0));

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Archivo Central HR',
      subtitle: 'Historial de Registros Laborales',
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF151C2B),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'excel', child: Row(children: [Icon(Icons.table_chart, color: Color(0xFF00E676), size: 18), SizedBox(width: 8), Text('Exportar Excel', style: TextStyle(color: Colors.white))])),
            const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, color: Color(0xFFFF5252), size: 18), SizedBox(width: 8), Text('Exportar PDF', style: TextStyle(color: Colors.white))])),
            const PopupMenuItem(value: 'backup', child: Row(children: [Icon(Icons.backup, color: Color(0xFF00E5FF), size: 18), SizedBox(width: 8), Text('Backup JSON', style: TextStyle(color: Colors.white))])),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'import', child: Row(children: [Icon(Icons.upload_file, color: Color(0xFFF4D35E), size: 18), SizedBox(width: 8), Text('Importar Backup', style: TextStyle(color: Colors.white))])),
          ],
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCards(),
                    const SizedBox(height: 16),
                    _buildFilters(),
                    const SizedBox(height: 16),
                    _buildTotalBar(),
                    const SizedBox(height: 20),
                    _buildRecordsList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    final planillas = _records.where((r) => r.type == HRRecordType.planilla).length;
    final liquidaciones = _records.where((r) => r.type == HRRecordType.liquidacion).length;
    final total = _records.fold<double>(0, (sum, r) => sum + (r.amount ?? 0));
    
    return Row(
      children: [
        Expanded(child: _buildStatCard('Planillas', '$planillas', Icons.receipt_long, const Color(0xFF00E5FF))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Liquidaciones', '$liquidaciones', Icons.description, const Color(0xFFF4D35E))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Total', '\$${total.toStringAsFixed(0)}', Icons.payments, const Color(0xFF00E676))),
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
          Icon(icon, color: color, size: 18),
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
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtros', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<HRRecordType?>(
                  value: _filterType,
                  dropdownColor: const Color(0xFF0F1520),
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos', style: TextStyle(color: Colors.white))),
                    ...HRRecordType.values.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text('${t.icon} ${t.label}', style: const TextStyle(color: Colors.white)),
                    )),
                  ],
                  onChanged: (v) => setState(() => _filterType = v),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: DropdownButtonFormField<int>(
                  value: _filterYear,
                  dropdownColor: const Color(0xFF0F1520),
                  decoration: const InputDecoration(
                    labelText: 'Año',
                    labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  items: [for (int y = DateTime.now().year; y >= 2020; y--) 
                    DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(color: Colors.white, fontSize: 12)))
                  ],
                  onChanged: (v) => setState(() => _filterYear = v ?? DateTime.now().year),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _filterWorkerId,
            dropdownColor: const Color(0xFF0F1520),
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Empleado',
              labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem(value: 'all', child: Text('Todos los empleados', style: TextStyle(color: Colors.white))),
              ..._workers.map((w) => DropdownMenuItem(
                value: w.id,
                child: Text(w.name, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
              )),
            ],
            onChanged: (v) => setState(() => _filterWorkerId = v ?? 'all'),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00E676).withOpacity(0.15), const Color(0xFF00E5FF).withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize, color: Color(0xFF00E676), size: 20),
              const SizedBox(width: 8),
              Text('${_filteredRecords.length} registros', style: GoogleFonts.outfit(color: Colors.white70)),
            ],
          ),
          Text('\$${_totalAmount.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: const Color(0xFF00E676), fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_filteredRecords.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.white.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text('No hay registros', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Los registros aparecerán aquí al calcular planillas o liquidaciones.', textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredRecords.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildRecordCard(_filteredRecords[index]),
    );
  }

  Widget _buildRecordCard(HRCentralRecord record) {
    final typeColor = _getTypeColor(record.type);
    
    return InkWell(
      onTap: () => _showRecordDetail(record),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151C2B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: typeColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(record.type.icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.workerName, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(record.description, style: GoogleFonts.outfit(color: typeColor, fontSize: 12)),
                  Text(DateFormat('dd/MM/yyyy').format(record.eventDate), style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (record.amount != null)
                  Text('\$${record.amount!.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: const Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 16)),
                Text(record.type.label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(HRRecordType type) {
    switch (type) {
      case HRRecordType.planilla: return const Color(0xFF00E5FF);
      case HRRecordType.liquidacion: return const Color(0xFFF4D35E);
      case HRRecordType.despido: return Colors.redAccent;
      case HRRecordType.renuncia: return Colors.orangeAccent;
      case HRRecordType.vacaciones: return const Color(0xFF00E676);
      case HRRecordType.aumento: return Colors.purpleAccent;
      default: return Colors.white54;
    }
  }

  void _showRecordDetail(HRCentralRecord record) {
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getTypeColor(record.type).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(record.type.icon, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.workerName, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('${record.type.label} - ${record.description}', style: GoogleFonts.outfit(color: _getTypeColor(record.type), fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Fecha', DateFormat('dd MMMM yyyy', 'es').format(record.eventDate)),
              _buildDetailRow('Tipo', record.type.label),
              if (record.amount != null) _buildDetailRow('Monto', '\$${record.amount!.toStringAsFixed(2)}'),
              if (record.data.isNotEmpty) ...[
                const Divider(color: Colors.white24, height: 24),
                ...record.data.entries.map((e) => _buildDetailRow(e.key, e.value.toString())),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                      label: const Text('Cerrar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deleteRecord(record);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.2), foregroundColor: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  Future<void> _deleteRecord(HRCentralRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151C2B),
        title: Text('¿Eliminar registro?', style: GoogleFonts.outfit(color: Colors.white)),
        content: Text('Esta acción no se puede deshacer.', style: GoogleFonts.outfit(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    
    if (confirm == true) {
      await _archiveService.delete(record.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro eliminado'), backgroundColor: Colors.redAccent));
      }
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'excel':
        _exportExcel();
        break;
      case 'pdf':
        _exportPDF();
        break;
      case 'backup':
        _exportBackup();
        break;
      case 'import':
        _importBackup();
        break;
    }
  }

  Future<void> _exportExcel() async {
    // Generate CSV (simpler than Excel for web)
    final buffer = StringBuffer();
    buffer.writeln('Empleado,Tipo,Fecha,Descripcion,Monto');
    for (final r in _filteredRecords) {
      buffer.writeln('"${r.workerName}","${r.type.label}","${DateFormat('dd/MM/yyyy').format(r.eventDate)}","${r.description}","${r.amount ?? 0}"');
    }
    
    final bytes = utf8.encode(buffer.toString());
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'archivo_hr_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Archivo CSV descargado'), backgroundColor: Color(0xFF00E676)));
  }

  Future<void> _exportPDF() async {
    // For web, generate a printable HTML page
    final html_content = '''
<!DOCTYPE html>
<html>
<head>
  <title>Archivo HR - Empodérate</title>
  <style>
    body { font-family: Arial, sans-serif; padding: 20px; }
    h1 { color: #00E5FF; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #151C2B; color: white; }
    .amount { text-align: right; color: #00E676; font-weight: bold; }
    .footer { margin-top: 30px; font-size: 12px; color: #666; }
  </style>
</head>
<body>
  <h1>📁 Archivo Central de Recursos Humanos</h1>
  <p>Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}</p>
  <p><strong>Total:</strong> \$${_totalAmount.toStringAsFixed(2)} | <strong>Registros:</strong> ${_filteredRecords.length}</p>
  <table>
    <tr><th>Empleado</th><th>Tipo</th><th>Fecha</th><th>Descripción</th><th>Monto</th></tr>
    ${_filteredRecords.map((r) => '<tr><td>${r.workerName}</td><td>${r.type.label}</td><td>${DateFormat('dd/MM/yyyy').format(r.eventDate)}</td><td>${r.description}</td><td class="amount">\$${(r.amount ?? 0).toStringAsFixed(2)}</td></tr>').join()}
  </table>
  <div class="footer">
    <p>Generado por EMPODÉRATE - Sistema de Gestión de Recursos Humanos</p>
  </div>
</body>
</html>
''';
    
    final bytes = utf8.encode(html_content);
    final blob = html.Blob([bytes], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Reporte abierto - usa Ctrl+P para imprimir como PDF'), backgroundColor: Color(0xFF00E676)));
  }

  Future<void> _exportBackup() async {
    final json = await _archiveService.exportBackupJson();
    final bytes = utf8.encode(json);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'hr_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json')
      ..click();
    html.Url.revokeObjectUrl(url);
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Backup JSON descargado - Guárdalo en Drive para respaldo'), backgroundColor: Color(0xFF00E5FF)));
  }

  Future<void> _importBackup() async {
    final input = html.FileUploadInputElement()..accept = '.json';
    input.click();
    
    input.onChange.listen((event) async {
      final file = input.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsText(file);
        reader.onLoadEnd.listen((event) async {
          final content = reader.result as String;
          final count = await _archiveService.importFromJson(content);
          if (count >= 0) {
            _loadData();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ $count registros importados'), backgroundColor: const Color(0xFF00E676)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Error al importar archivo'), backgroundColor: Colors.redAccent));
          }
        });
      }
    });
  }
}
