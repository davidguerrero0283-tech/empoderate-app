import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/features/checklist/checklist_model.dart';
import 'package:proyecto_empoderate/src/features/checklist/checklist_service.dart';

class ChecklistTramitesScreen extends StatefulWidget {
  const ChecklistTramitesScreen({Key? key}) : super(key: key);

  @override
  State<ChecklistTramitesScreen> createState() => _ChecklistTramitesScreenState();
}

class _ChecklistTramitesScreenState extends State<ChecklistTramitesScreen> with SingleTickerProviderStateMixin {
  List<ChecklistItem> _items = [];
  bool _isLoading = true;
  late TabController _tabController;

  final List<ChecklistCategory> _tabs = [
    ChecklistCategory.legal,
    ChecklistCategory.fiscal,
    ChecklistCategory.municipal,
    ChecklistCategory.laboral,
    ChecklistCategory.operativo,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await ChecklistService.loadItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  void _toggleItem(ChecklistItem item, bool? val) {
    setState(() {
      item.isCompleted = val ?? false;
    });
    ChecklistService.saveStatus(_items);
  }

  void _resetProgress() async {
    await ChecklistService.resetAll();
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progreso reiniciado.')));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const PremiumScaffold(
        title: 'TRAMITES',
        body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
      );
    }

    final int total = _items.length;
    final int completed = _items.where((i) => i.isCompleted).length;
    final double progress = total > 0 ? completed / total : 0.0;

    return PremiumScaffold(
      title: 'CHECKLIST DE TRÁMITES',
      isNeonTitle: true,
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white54),
          tooltip: 'Reiniciar',
          onPressed: _resetProgress,
        )
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER PROGRESS
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFD4AF37).withOpacity(0.2), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFD4AF37)),
                  backgroundColor: Colors.white10,
                  strokeWidth: 6,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cumplimiento Global: ${(progress * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completed de $total requisitos completados',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          NeonButton(
             text: 'VER TRÁMITES ESPECÍFICOS POR RUBRO',
             icon: Icons.storefront,
             onTap: () => Navigator.pushNamed(context, '/checklist/rubro_selection'),
             primary: false,
             color: Colors.tealAccent,
          ),
          const SizedBox(height: 24),

          // TABS
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: const Color(0xFFD4AF37),
            labelColor: const Color(0xFFD4AF37),
            unselectedLabelColor: Colors.white54,
            labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
            tabs: _tabs.map((c) => Tab(text: c.label.split('/')[0])).toList(), // Short label
          ),
          const SizedBox(height: 16),

          // LIST VIEW
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((category) => _buildCategoryList(category)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(ChecklistCategory category) {
    final categoryItems = _items.where((i) => i.category == category).toList();

    if (categoryItems.isEmpty) {
      return Center(child: Text('No hay requisitos en esta categoría.', style: GoogleFonts.outfit(color: Colors.white30)));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 40),
      itemCount: categoryItems.length,
      itemBuilder: (context, index) {
        final item = categoryItems[index]; // Fixed: access from filtered list
        return _buildCheckItem(item);
      },
    );
  }

  Widget _buildCheckItem(ChecklistItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.isCompleted ? const Color(0xFFD4AF37).withOpacity(0.5) : Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Checkbox(
            value: item.isCompleted,
            activeColor: const Color(0xFFD4AF37),
            checkColor: Colors.black,
            side: const BorderSide(color: Colors.white54),
            onChanged: (val) => _toggleItem(item, val),
          ),
          title: Text(
            item.title,
            style: GoogleFonts.outfit(
              color: item.isCompleted ? Colors.white54 : Colors.white,
              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Frecuencia: ${item.frequency}',
            style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 11),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
             const Divider(color: Colors.white10),
             Text(item.description, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
             
             if (item.toolRoute != null) ...[
               const SizedBox(height: 12),
               Align(
                 alignment: Alignment.centerLeft,
                 child: OutlinedButton.icon(
                   onPressed: () {
                     // Check if valid route (placeholder safety)
                     if (item.toolRoute!.isNotEmpty) {
                       Navigator.pushNamed(context, item.toolRoute!); 
                     }
                   }, 
                   icon: const Icon(Icons.launch, size: 14),
                   label: const Text('Ir a herramienta relacionada'),
                   style: OutlinedButton.styleFrom(
                     foregroundColor: Colors.tealAccent,
                     side: const BorderSide(color: Colors.tealAccent),
                   ),
                 ),
               )
             ]
          ],
        ),
      ),
    );
  }
}
