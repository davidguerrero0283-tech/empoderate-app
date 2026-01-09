import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../components/neon_widgets.dart';
import '../../features/system/services/audit_logger_service.dart';
import '../../features/system/models/audit_log_model.dart';
import '../../features/admin/services/admin_data_provider.dart'; // Keep for structure if needed, but using real service

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({Key? key}) : super(key: key);

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  String _searchQuery = '';
  String? _severityFilter;
  String? _typeFilter;
  bool _isLoading = false;
  List<AuditLog> _logs = [];

  final _typeOptions = ['User', 'Post', 'System', 'Auth'];
  
  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    // Ensure initialized
    await AuditLoggerService.instance.init();
    final logs = AuditLoggerService.instance.getLogs(
      searchQuery: _searchQuery,
      severityFilter: _severityFilter,
      typeFilter: _typeFilter,
    );
    if (mounted) {
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadLogs();
  }

  Future<void> _handleExport() async {
    final jsonStr = AuditLoggerService.instance.exportLogsJson();
    await Clipboard.setData(ClipboardData(text: jsonStr));
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logs copiados al portapapeles (JSON)')),
      );
    }
  }

  Future<void> _handleClear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Limpiar Bitácora?'),
        content: const Text('Esta acción es irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Limpiar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await AuditLoggerService.instance.clearLogs();
      await _loadLogs();
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitácora limpiada')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bitácora de Auditoría',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white54),
                    onPressed: _handleExport,
                    tooltip: 'Copiar JSON',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                    onPressed: _handleClear,
                    tooltip: 'Limpiar Logs',
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),

          // Search & Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Buscar logs...',
                    hintStyle: TextStyle(color: Colors.white30),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.white54),
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _loadLogs();
                  },
                ),
                const Divider(color: Colors.white10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todos', _severityFilter == null, () => setState(() { _severityFilter = null; _loadLogs(); })),
                      _buildFilterChip('Info', _severityFilter == 'info', () => setState(() { _severityFilter = 'info'; _loadLogs(); })),
                      _buildFilterChip('Warning', _severityFilter == 'warning', () => setState(() { _severityFilter = 'warning'; _loadLogs(); })),
                      _buildFilterChip('Error', _severityFilter == 'error', () => setState(() { _severityFilter = 'error'; _loadLogs(); })),
                      const SizedBox(width: 16),
                      // Type Filters
                      ..._typeOptions.map((t) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildFilterChip(t, _typeFilter == t, () {
                           setState(() {
                             _typeFilter = (_typeFilter == t) ? null : t;
                             _loadLogs();
                           });
                        }),
                      )).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Log List
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_logs.isEmpty)
             Center(
               child: Column(
                 children: [
                   const SizedBox(height: 40),
                   Icon(Icons.history_toggle_off, size: 48, color: Colors.white24),
                   const SizedBox(height: 16),
                   Text('No hay registros', style: GoogleFonts.outfit(color: Colors.white54)),
                 ],
               ),
             )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return _buildLogCard(log);
              },
            ),
            
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white10,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? Colors.white : Colors.transparent),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogCard(AuditLog log) {
    Color statusColor;
    IconData icon;
    
    switch(log.severity) {
      case 'error': statusColor = Colors.redAccent; icon = Icons.error_outline; break;
      case 'warning': statusColor = Colors.orangeAccent; icon = Icons.warning_amber; break;
      default: statusColor = Colors.blueAccent; icon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(12),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          title: Text(
            log.summary,
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                _buildTag(log.entityType, Colors.purpleAccent),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MM/dd HH:mm').format(log.timestamp),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          children: [
             Container(
               padding: const EdgeInsets.all(16),
               color: Colors.black12,
               width: double.infinity,
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   _buildDetailRow('ID', log.id),
                   _buildDetailRow('Actor', log.actor),
                   _buildDetailRow('Action', log.action),
                   _buildDetailRow('Entity ID', log.entityId),
                   if (log.meta.isNotEmpty) ...[
                     const SizedBox(height: 8),
                     const Text('Meta Data:', style: TextStyle(color: Colors.white54, fontSize: 11)),
                     const SizedBox(height: 4),
                     Text(
                       const JsonEncoder.withIndent('  ').convert(log.meta),
                       style: GoogleFonts.firaCode(color: Colors.greenAccent, fontSize: 11),
                     ),
                   ]
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10)),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text('$label:', style: const TextStyle(color: Colors.white38, fontSize: 12))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }
}
