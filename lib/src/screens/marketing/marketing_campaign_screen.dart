import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/features/marketing/marketing_models.dart';
import 'package:proyecto_empoderate/src/features/marketing/marketing_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/checklist_repository.dart';

class MarketingCampaignScreen extends StatefulWidget {
  const MarketingCampaignScreen({Key? key}) : super(key: key);

  @override
  State<MarketingCampaignScreen> createState() => _MarketingCampaignScreenState();
}

class _MarketingCampaignScreenState extends State<MarketingCampaignScreen> {
  final MarketingService _service = MarketingService();
  List<MarketingCampaign> _campaigns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _campaigns = _service.getCampaigns();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Gestor de Campañas',
      isNeonTitle: true,
      showBackButton: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCampaignDialog(),
        backgroundColor: const Color(0xFF448AFF),
        icon: const Icon(Icons.add),
        label: Text('Nueva Campaña', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF448AFF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const SizedBox(height: 16),
                   // KPI Summary Row
                   _buildKpiRow(),
                   const SizedBox(height: 32),
                   
                   NeonSectionTitle(title: 'Mis Campañas Activas', color: const Color(0xFF448AFF)),
                   const SizedBox(height: 16),
                   
                   // Pro Data Table
                   _buildCampaignTable(),
                ],
              ),
            ),
    );
  }

  // ... (KPI Methods remain same)

  Widget _buildKpiRow() {
    // Calc totals
    double totalBudget = _campaigns.fold(0, (sum, c) => sum + c.budget);
    double totalSpend = _campaigns.fold(0, (sum, c) => sum + c.spent);
    int totalConv = _campaigns.fold(0, (sum, c) => sum + c.conversions);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildKpiCard('Presupuesto Total', '\$${totalBudget.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.blueGrey),
          const SizedBox(width: 12),
          _buildKpiCard('Gasto Actual', '\$${totalSpend.toStringAsFixed(2)}', Icons.money_off, Colors.orangeAccent),
          const SizedBox(width: 12),
          _buildKpiCard('Conversiones', '$totalConv', Icons.ads_click, Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCampaignTable() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1520),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
          dataRowColor: MaterialStateProperty.all(Colors.transparent),
          columnSpacing: 24,
          columns: [
            DataColumn(label: Text('Estado', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Campaña', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Plataforma', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Gasto', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ROI', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Acción', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold))),
          ],
          rows: _campaigns.map((c) {
            return DataRow(cells: [
              DataCell(_buildStatusBadge(c.status)),
              DataCell(Text(c.name, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500))),
              DataCell(Row(
                children: [
                  Icon(_getPlatformIcon(c.platform), size: 16, color: Colors.white54),
                  const SizedBox(width: 8),
                  Text(c.platform, style: GoogleFonts.outfit(color: Colors.white70)),
                ],
              )),
              DataCell(Text('\$${c.spent.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.white70))),
              DataCell(Text('${c.roi.toStringAsFixed(1)}%', style: GoogleFonts.outfit(color: c.roi > 0 ? Colors.greenAccent : Colors.redAccent))),
              DataCell(PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white30),
                onSelected: (value) {
                  if (value == 'edit') _showCampaignDialog(campaign: c);
                  if (value == 'delete') _deleteCampaign(c.id);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.redAccent))),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  // ... (Helpers remain same)
  Widget _buildStatusBadge(CampaignStatus status) {
    Color color;
    String text;
    switch (status) {
      case CampaignStatus.active: color = Colors.greenAccent; text = 'ACTIVO'; break;
      case CampaignStatus.paused: color = Colors.orangeAccent; text = 'PAUSADO'; break;
      case CampaignStatus.completed: color = Colors.blueGrey; text = 'FIN'; break;
      default: color = Colors.grey; text = 'BORRADOR';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook': return Icons.facebook;
      case 'instagram': return Icons.camera_alt;
      case 'google': return Icons.search;
      case 'tiktok': return Icons.music_note;
      default: return Icons.public;
    }
  }

  // Logic Actions
  void _deleteCampaign(String id) {
    setState(() {
      _service.deleteCampaign(id);
      _campaigns = _service.getCampaigns();
    });
  }

  void _showCampaignDialog({MarketingCampaign? campaign}) {
    final isEditing = campaign != null;
    final nameCtrl = TextEditingController(text: campaign?.name ?? '');
    final budgetCtrl = TextEditingController(text: campaign?.budget.toString() ?? '');
    String platform = campaign?.platform ?? 'Instagram';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151C2B),
        title: Text(isEditing ? 'Editar Campaña' : 'Nueva Campaña', style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonInput(label: 'Nombre de Campaña', controller: nameCtrl),
            const SizedBox(height: 12),
            NeonInput(label: 'Presupuesto Total', controller: budgetCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: platform,
              dropdownColor: const Color(0xFF151C2B),
              style: GoogleFonts.outfit(color: Colors.white),
              items: ['Instagram', 'Facebook', 'TikTok', 'Google']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => platform = v!,
              decoration: InputDecoration(
                labelText: 'Plataforma',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF448AFF)),
            onPressed: () {
              final newCampaign = MarketingCampaign(
                id: campaign?.id ?? DateTime.now().toString(),
                name: nameCtrl.text,
                platform: platform,
                startDate: DateTime.now(),
                budget: double.tryParse(budgetCtrl.text) ?? 0.0,
                spent: campaign?.spent ?? 0.0,
                impressions: campaign?.impressions ?? 0,
                clicks: campaign?.clicks ?? 0,
                conversions: campaign?.conversions ?? 0,
                status: CampaignStatus.active,
              );

              if (isEditing) {
                _service.updateCampaign(newCampaign);
              } else {
                _service.addCampaign(newCampaign);
              }
              
              // SIGNAL UPDATE
              SharedPreferences.getInstance().then((prefs) {
                prefs.setInt('marketing.campaign_count', _service.getCampaigns().length);
                ChecklistRepository().refresh();
              });

              setState(() {
                _campaigns = _service.getCampaigns();
              });
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Guardar' : 'Crear'),
          )
        ],
      ),
    );
  }
}
