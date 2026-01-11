import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/premium_scaffold.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import '../services/compliance_checklist_service.dart';

class ComplianceChecklistScreen extends StatefulWidget {
  const ComplianceChecklistScreen({super.key});

  @override
  State<ComplianceChecklistScreen> createState() => _ComplianceChecklistScreenState();
}

class _ComplianceChecklistScreenState extends State<ComplianceChecklistScreen> {
  final ComplianceChecklistService _service = ComplianceChecklistService();
  List<ChecklistItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _service.loadItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _toggleItem(String itemId, bool value) async {
    await _service.toggleItem(itemId, value);
    _loadItems();
  }

  Future<void> _resetAll() async {
    await _service.resetAll();
    _loadItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checklist reiniciado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _items.where((i) => i.isCompleted).length;
    final total = _items.length;
    final percent = total == 0 ? 0.0 : completed / total;

    return PremiumScaffold(
      title: 'Checklist de Cumplimiento',
      isNeonTitle: true,
      showBackButton: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Header
                  _buildProgressHeader(completed, total, percent),
                  const SizedBox(height: 24),

                  // Checklist Items
                  ..._buildGroupedItems(),

                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _resetAll,
                          icon: const Icon(Icons.restart_alt, size: 18),
                          label: const Text('Restablecer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressHeader(int completed, int total, double percent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EmpoderateTheme.gold.withOpacity(0.15),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EmpoderateTheme.gold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: EmpoderateTheme.gold.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.checklist, color: EmpoderateTheme.gold, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progreso de Cumplimiento',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed de $total completado (${(percent * 100).toInt()}%)',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  color: EmpoderateTheme.gold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 1.0 ? Colors.greenAccent : EmpoderateTheme.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedItems() {
    // Group by category
    final Map<String, List<ChecklistItem>> grouped = {};
    for (var item in _items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final categoryLabels = {
      'planilla': 'Planilla',
      'seguro_social': 'Seguro Social (CSS)',
      'pagos': 'Pagos',
      'documentos': 'Documentación',
      'permisos': 'Permisos y Licencias',
      'vacaciones': 'Vacaciones',
      'legal': 'Cumplimiento Legal',
      'general': 'General',
    };

    final widgets = <Widget>[];
    grouped.forEach((category, items) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            categoryLabels[category] ?? category,
            style: GoogleFonts.outfit(
              color: EmpoderateTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      for (var item in items) {
        widgets.add(_buildChecklistItem(item));
      }
    });

    return widgets;
  }

  Widget _buildChecklistItem(ChecklistItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: item.isCompleted ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isCompleted ? Colors.green.withOpacity(0.3) : Colors.white10,
        ),
      ),
      child: CheckboxListTile(
        value: item.isCompleted,
        onChanged: (val) => _toggleItem(item.id, val ?? false),
        title: Text(
          item.title,
          style: GoogleFonts.outfit(
            color: item.isCompleted ? Colors.green : Colors.white,
            fontSize: 14,
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        checkColor: Colors.black,
        activeColor: Colors.greenAccent,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}
