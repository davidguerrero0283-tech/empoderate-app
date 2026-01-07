import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../hr_compliance_service.dart';
import '../hr_compliance_models.dart';
import '../../../../components/neon_widgets.dart';

class ComplianceManagerTab extends StatefulWidget {
  final VoidCallback onDataChanged;
  const ComplianceManagerTab({Key? key, required this.onDataChanged}) : super(key: key);

  @override
  State<ComplianceManagerTab> createState() => _ComplianceManagerTabState();
}

class _ComplianceManagerTabState extends State<ComplianceManagerTab> {
  final _service = HrComplianceService();
  List<HrObligationCatalog> _catalog = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() => _loading = true);
    await _service.init();
    final list = _service.getCatalog();
    if (mounted) {
      setState(() {
        _catalog = list;
        _loading = false;
      });
    }
  }

  Future<void> _deleteItem(String id) async {
    await _service.deleteCatalogItem(id);
    _loadCatalog();
    widget.onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
    }

    return Column(
      children: [
        // Header / Intro
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Icon(Icons.settings_suggest, color: Colors.cyanAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gestiona tu catálogo de obligaciones. Las activas se generarán automáticamente mes a mes.',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Catalog List
        if (_catalog.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40.0),
            child: Text('No hay obligaciones configuradas', style: TextStyle(color: Colors.white38)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _catalog.length,
            itemBuilder: (context, index) {
               final item = _catalog[index];
               return _CatalogItemCard(
                 item: item, 
                 onDelete: () => _deleteItem(item.id),
               );
            },
          ),
          
        const SizedBox(height: 20),
        // Action Buttons for Templates (Mock for now, could open modal)
        NeonButton(
          text: "Recargar Datos de Ejemplo (Demo)", 
          onTap: () async {
            await _service.loadDemoData();
            _loadCatalog();
            widget.onDataChanged();
          },
          icon: Icons.refresh,
          primary: false,
        )
      ],
    );
  }
}

class _CatalogItemCard extends StatelessWidget {
  final HrObligationCatalog item;
  final VoidCallback onDelete;

  const _CatalogItemCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.frequency} • ${item.dueRule ?? "-"}',
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: onDelete,
          )
        ],
      ),
    );
  }
}
