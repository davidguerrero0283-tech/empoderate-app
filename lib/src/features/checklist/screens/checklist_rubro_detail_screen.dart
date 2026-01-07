import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import 'package:proyecto_empoderate/src/features/checklist/checklist_model.dart';
import 'package:proyecto_empoderate/src/features/checklist/checklist_service.dart';
// import 'package:proyecto_empoderate/src/features/agenda/models/agenda_models.dart'; // OLD - REMOVED
// import 'package:proyecto_empoderate/src/features/agenda/services/agenda_service.dart'; // OLD - REMOVED

class ChecklistRubroDetailScreen extends StatefulWidget {
  final String rubroId;
  final String title;

  const ChecklistRubroDetailScreen({Key? key, required this.rubroId, required this.title}) : super(key: key);

  @override
  State<ChecklistRubroDetailScreen> createState() => _ChecklistRubroDetailScreenState();
}

class _ChecklistRubroDetailScreenState extends State<ChecklistRubroDetailScreen> {
  List<ChecklistItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await ChecklistService.loadItems(rubroId: widget.rubroId);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return PremiumScaffold(
        title:  widget.title.toUpperCase(),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
      );
    }

    if (_items.isEmpty) {
      return PremiumScaffold(
        title: widget.title.toUpperCase(),
        showBackButton: true,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sentiment_dissatisfied, size: 48, color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                'Aún no tenemos requisitos cargados para este rubro.',
                style: GoogleFonts.outfit(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              )
            ],
          ),
        ),
      );
    }

    final int total = _items.length;
    final int completed = _items.where((i) => i.isCompleted).length;
    final double progress = total > 0 ? completed / total : 0.0;

    return PremiumScaffold(
      title: widget.title.toUpperCase(),
      isNeonTitle: true,
      showBackButton: true,
      body: Column(
        children: [
          // HEADER
          // HEADER
          NeonWideCard(
            borderColor: EmpoderateTheme.goldStrong,
            child: Row(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  valueColor: const AlwaysStoppedAnimation(EmpoderateTheme.goldStrong),
                  backgroundColor: Colors.white10,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progreso del Rubro',
                        style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% Completado',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildCheckItem(_items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Reusing logic (should ideally extract widget)
  Widget _buildCheckItem(ChecklistItem item) {
    // Uses Centralized Premium Style
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: EmpoderateTheme.premiumGlassCard.copyWith(
        border: Border.all(
          color: item.isCompleted 
              ? EmpoderateTheme.goldStrong 
              : EmpoderateTheme.goldStrong.withOpacity(0.1)
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: EmpoderateTheme.goldStrong,
          iconColor: EmpoderateTheme.goldStrong,
          leading: Checkbox(
            value: item.isCompleted,
            activeColor: EmpoderateTheme.goldStrong,
            checkColor: Colors.black,
            side: BorderSide(color: Colors.white54),
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
            style: GoogleFonts.outfit(color: Colors.white30, fontSize: 11),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
             const Divider(color: Colors.white10),
             Text(item.description, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
             const SizedBox(height: 16),
             Row(
               mainAxisAlignment: MainAxisAlignment.end,
               children: [
                 ElevatedButton.icon(
                   onPressed: () => _addToAgenda(item),
                   icon: const Icon(Icons.calendar_today, size: 14, color: Colors.black),
                   label: Text('AGREGAR A AGENDA', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: EmpoderateTheme.goldStrong,
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   ),
                 ),
               ],
             ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToAgenda(ChecklistItem item) async {
    // OLD AgendaService removed - navigate to new Agenda instead
    Navigator.pushNamed(context, '/agenda_tramites');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abre la Agenda para agregar este trámite manualmente'),
        backgroundColor: EmpoderateTheme.goldStrong,
      ),
    );
  }
}
