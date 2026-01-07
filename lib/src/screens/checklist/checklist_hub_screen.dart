import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/premium_scaffold.dart';
import '../../data/repositories/checklist_repository.dart';
import '../../models/checklist_model.dart';

class ChecklistHubScreen extends StatefulWidget {
  final int? initialTabIndex; // Support direct tab navigation

  const ChecklistHubScreen({Key? key, this.initialTabIndex}) : super(key: key);

  @override
  State<ChecklistHubScreen> createState() => _ChecklistHubScreenState();
}

class _ChecklistHubScreenState extends State<ChecklistHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repository = ChecklistRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTabIndex ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Checklist de Negocio',
      showBackButton: true,
      useScroll: false, // REQUIRED for Column > Expanded > TabBarView layout
      actions: [
        IconButton(
          onPressed: () => _showSourceInfo(context),
          icon: const Icon(Icons.info_outline, color: Colors.white54),
          tooltip: 'Fuentes de datos',
        ),
        IconButton(
          onPressed: () async {
            await _repository.refresh();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progreso recalculado'), duration: Duration(milliseconds: 800)));
          },
          icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
          tooltip: 'Recalcular progreso',
        ),
      ],
      body: StreamBuilder<BusinessProgressModel>(
        stream: _repository.watchDashboard,
        initialData: _repository.currentDashboard,
        builder: (context, snapshot) {
          final dashboard = snapshot.data ?? BusinessProgressModel.empty;

          return Column(
            children: [
              // Overall Status Mini-Header
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2342),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 40, height: 40,
                          child: CircularProgressIndicator(
                            value: dashboard.overall.percent,
                            backgroundColor: Colors.white10,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                        Text(
                          "${(dashboard.overall.percent * 100).toInt()}%",
                          style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Progreso General (Ponderado)", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(
                            "Siguiente: ${dashboard.overall.nextTitle ?? '¡Todo listo!'}",
                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: const Color(0xFFD4AF37),
                labelColor: const Color(0xFFD4AF37),
                unselectedLabelColor: Colors.white54,
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "Inicio (40%)"),
                  Tab(text: "Planilla (20%)"),
                  Tab(text: "Contab. (20%)"),
                  Tab(text: "Market. (20%)"),
                ],
              ),
              
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChecklistList(ProgressArea.start),
                    _buildChecklistList(ProgressArea.payroll),
                    _buildChecklistList(ProgressArea.accounting),
                    _buildChecklistList(ProgressArea.marketing),
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildChecklistList(ProgressArea area) {
    return StreamBuilder<List<ChecklistItem>>(
      stream: _repository.watchItems,
      initialData: _repository.currentItems,
      builder: (context, snapshot) {
        final allItems = snapshot.data ?? [];
        final areaItems = allItems.where((i) => i.area == area).toList();
        areaItems.sort((a, b) => a.order.compareTo(b.order));

        if (areaItems.isEmpty) {
          return Center(child: Text("Sin configurar (0 items)", style: GoogleFonts.outfit(color: Colors.white38)));
        }

        return ListView.builder(
          itemCount: areaItems.length,
          itemBuilder: (context, index) {
            final item = areaItems[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1623), // Darker card
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: item.done ? Colors.green.withOpacity(0.3) : Colors.white12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox
                       Transform.scale(
                         scale: 1.1,
                         child: Checkbox(
                          value: item.done,
                          activeColor: const Color(0xFFD4AF37),
                          side: BorderSide(color: Colors.white24, width: 2),
                          onChanged: (val) {
                             if (item.autoRuleKey != null) {
                                // Show toast: "This is automatic"
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este ítem se completa automáticamente cuando detecta la data.'), duration: Duration(seconds: 2)));
                             } else {
                                _repository.toggleItemDone(item.id);
                             }
                          },
                         ),
                       ),
                       const SizedBox(width: 8),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               item.title, 
                               style: GoogleFonts.outfit(
                                 color: item.done ? Colors.white38 : Colors.white,
                                 fontSize: 15,
                                 fontWeight: FontWeight.w600,
                                 decoration: item.done ? TextDecoration.lineThrough : null,
                               )
                             ),
                             if (item.description != null)
                               Padding(
                                 padding: const EdgeInsets.only(top: 4),
                                 child: Text(
                                   item.description!,
                                   style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
                                 ),
                               ),
                           ],
                         ),
                       )
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Footer Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // CHIP STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.autoRuleKey != null ? Colors.blue.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: item.autoRuleKey != null ? Colors.blue.withOpacity(0.3) : Colors.white12),
                        ),
                        child: Text(
                           item.autoRuleKey != null ? "AUTO" : "MANUAL",
                           style: GoogleFonts.outfit(color: item.autoRuleKey != null ? Colors.blueAccent : Colors.white24, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      // ACTION BUTTON
                      if (item.route != null)
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, item.route!),
                        child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           decoration: BoxDecoration(
                             color: const Color(0xFFD4AF37).withOpacity(0.1),
                             borderRadius: BorderRadius.circular(20),
                             border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                           ),
                           child: Row(
                             children: [
                               Text("Ir a módulo", style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold)),
                               const SizedBox(width: 4),
                               const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 10),
                             ],
                           ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      }
    );

  } 
  
  void _showSourceInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151C2B),
        title: Text('¿De dónde salen estos datos?', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sourceItem('Inicio', 'Configuración de rubro y primeros pasos.'),
            _sourceItem('Planilla', 'Registro de empleados y cumplimiento de obligaciones del mes.'),
            _sourceItem('Contabilidad', 'Presupuesto guardado, Flujo de caja y Análisis de costos.'),
            _sourceItem('Marketing', 'Definición de avatar, embudo y campañas activas.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido')),
        ],
      ),
    );
  }
  
  Widget _sourceItem(String label, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          Text(desc, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
