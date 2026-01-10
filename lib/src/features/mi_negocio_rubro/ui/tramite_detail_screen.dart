
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart'; // For Button
import '../data/rubro_tramites_repository.dart';
import '../../boveda/services/boveda_service.dart';
import '../../boveda/models/doc_model.dart';

class TramiteDetailScreen extends StatefulWidget {
  final String categoryId;
  final String rubroId;
  final String tramiteId;

  const TramiteDetailScreen({
    Key? key,
    required this.categoryId,
    required this.rubroId,
    required this.tramiteId,
  }) : super(key: key);

  @override
  State<TramiteDetailScreen> createState() => _TramiteDetailScreenState();
}

class _TramiteDetailScreenState extends State<TramiteDetailScreen> {
  // Persistence state
  Set<String> _checkedItems = {};
  List<DocModel> _attachedDocs = []; 
  bool _isLoading = true;

  String get _storageKey => 'tramite_progress_${widget.categoryId}_${widget.rubroId}_${widget.tramiteId}';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _checkedItems = (prefs.getStringList(_storageKey) ?? []).toSet();
      _isLoading = false;
    });
    _refreshDocs();
  }

  Future<void> _refreshDocs() async {
      final boveda = BovedaService();
      final allDocs = boveda.documents;
      final matchPrefix = '[${widget.tramiteId.toUpperCase()}]';
      
      setState(() {
         _attachedDocs = allDocs.where((d) => d.title.startsWith(matchPrefix)).toList();
      });
  }

  Future<void> _toggleItem(String itemKey) async {
    setState(() {
      if (_checkedItems.contains(itemKey)) {
        _checkedItems.remove(itemKey);
      } else {
        _checkedItems.add(itemKey);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _checkedItems.toList());
  }

  Future<void> _attachDocument() async {
     // Simulate file picking for web demo
     // In real app: FilePicker.platform.pickFiles()
     final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
     final docTitle = '[${widget.tramiteId.toUpperCase()}] Documento $timestamp';
     
     final boveda = BovedaService();
     await boveda.saveDocument(
       title: docTitle,
       category: DocCategory.legal,
       content: "Contenido simulado del documento...", // Simulated content size
       extension: '.pdf'
     );

     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: const Text('Documento guardado en Bóveda Digital'),
         backgroundColor: EmpoderateTheme.goldStrong,
       )
     );
     _refreshDocs();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));

    final detail = RubroTramitesRepository.getTramiteDetail(widget.tramiteId);

    if (detail == null) {
       return PremiumScaffold(
         title: 'DETALLE DEL TRÁMITE',
         showBackButton: true,
         body: Center(child: Text('Trámite no encontrado', style: GoogleFonts.outfit(color: Colors.white54))),
       );
    }

    // Determine Status
    final totalItems = detail.requisitos.length + detail.pasos.length;
    final checkedCount = _checkedItems.where((k) => k.startsWith('req_') || k.startsWith('paso_')).length;
    final isCompleted = totalItems > 0 && checkedCount == totalItems;
    final percent = totalItems > 0 ? (checkedCount / totalItems) : 0.0;

    return PremiumScaffold(
      title: detail.nombre.toUpperCase(),
      // subtitle: detail.entidad?.toUpperCase() ?? 'TRÁMITE', // Moved to Hero
      showBackButton: true,
      isNeonTitle: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- PRO HERO HEADER ---
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  // Hero Icon with Glow
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: EmpoderateTheme.goldStrong.withOpacity(0.3)),
                      boxShadow: [
                         BoxShadow(color: EmpoderateTheme.goldStrong.withOpacity(0.1), blurRadius: 15, spreadRadius: 2)
                      ]
                    ),
                    child: Icon(
                      _getIconForEntity(detail.entidad), 
                      color: EmpoderateTheme.goldStrong, 
                      size: 30
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Title & Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                           detail.entidad?.toUpperCase() ?? 'TRÁMITE',
                           style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)
                         ),
                         const SizedBox(height: 4),
                         Text(
                           detail.nombre, 
                           style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                           maxLines: 2, overflow: TextOverflow.ellipsis,
                         ),
                         const SizedBox(height: 8),
                         
                         // Status Badge & Progress
                         Row(
                           children: [
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(
                                 color: isCompleted ? EmpoderateTheme.goldStrong : Colors.white10,
                                 borderRadius: BorderRadius.circular(20),
                                 border: Border.all(color: isCompleted ? EmpoderateTheme.goldStrong : Colors.white24),
                                 boxShadow: isCompleted ? [BoxShadow(color: EmpoderateTheme.goldStrong.withOpacity(0.4), blurRadius: 8)] : null
                               ),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Icon(
                                     isCompleted ? Icons.check_circle : Icons.pending_outlined, 
                                     size: 12, 
                                     color: isCompleted ? Colors.black : Colors.white70
                                   ),
                                   const SizedBox(width: 6),
                                   Text(
                                     isCompleted ? 'COMPLETADO' : 'PENDIENTE', 
                                     style: GoogleFonts.outfit(
                                       color: isCompleted ? Colors.black : Colors.white70, 
                                       fontSize: 10, 
                                       fontWeight: FontWeight.bold
                                     )
                                   ),
                                 ],
                               )
                             ),
                             if (!isCompleted && totalItems > 0) ...[
                               const SizedBox(width: 12),
                               Text('${(percent * 100).toInt()}%', style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontSize: 12, fontWeight: FontWeight.bold)),
                             ]
                           ],
                         )
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            // --- GLASS METRICS GRID ---
            if (detail.tiempo != null || detail.costo != null || detail.frecuenciaPago != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    if (detail.tiempo != null) 
                       Expanded(child: _buildGlassMetric(Icons.timer_outlined, 'TIEMPO', detail.tiempo!)),
                    if (detail.tiempo != null) const SizedBox(width: 12),
                    
                    if (detail.costo != null)
                       Expanded(child: _buildGlassMetric(Icons.attach_money, 'COSTO', detail.costo!)),
                    if (detail.costo != null && detail.frecuenciaPago != null) const SizedBox(width: 12),
                    
                    if (detail.frecuenciaPago != null)
                       Expanded(child: _buildGlassMetric(Icons.repeat, 'PAGO', detail.frecuenciaPago!)),
                  ],
                ),
              ),

             // --- QUICK ACTIONS ---
            if (detail.onlineLink != null || detail.dondeSacar != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Row(
                   children: [
                     if (detail.onlineLink != null)
                       Expanded(
                         child: _buildQuickActionBtn(
                           icon: Icons.public, 
                           label: 'SITIO WEB', 
                           color: Colors.blueAccent,
                           onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abriendo: ${detail.onlineLink}')))
                         )
                       ),
                     if (detail.onlineLink != null && detail.dondeSacar != null) const SizedBox(width: 12),
                     
                     if (detail.dondeSacar != null)
                       Expanded(
                         child: _buildQuickActionBtn(
                           icon: Icons.map, 
                           label: 'UBICACIÓN', 
                           color: Colors.pinkAccent,
                           onTap: () { /* Launch Maps */ } 
                         )
                       ),
                   ],
                ),
              ),


            // ATTACHMENT BUTTON (Primary Action)
            NeonButton(
                text: 'Adjuntar Documento',
                icon: Icons.upload_file,
                onTap: _attachDocument,
                // compact: true, 
                primary: true, // Prominent
            ),
            const SizedBox(height: 32),

            // EMPTY STATE CHECK
            if (detail.pasos.isEmpty && detail.requisitos.isEmpty)
              _buildEmptyState(),
            

            // TIPS SECTION (Redesigned)
            if (detail.tips.isNotEmpty)
              _buildTipsSection(detail.tips),

            // SOURCE SECTION (PROMPT 99)
            if (detail.fuente != null)
              _buildSourceSection(detail),

            // SECTIONS
            if (detail.requisitos.isNotEmpty)
              _buildChecklistSection('REQUISITOS', detail.requisitos, 'req'),
            
            if (detail.pasos.isNotEmpty)
               _buildChecklistSection('PASOS A SEGUIR', detail.pasos, 'paso', isStep: true),
            
               
            // ATTACHED DOCS LIST
            if (_attachedDocs.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                         children: [
                           const Icon(Icons.folder_open, color: EmpoderateTheme.goldStrong, size: 18),
                           const SizedBox(width: 8),
                           Text('DOCUMENTOS ADJUNTOS', style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontSize: 13, fontWeight: FontWeight.bold)),
                         ],
                      ),
                      const SizedBox(height: 16),
                      ..._attachedDocs.map((doc) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12)
                        ),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.picture_as_pdf, color: Colors.white70, size: 20),
                          title: Text(doc.title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
                          subtitle: Text(doc.sizeLabel, style: GoogleFonts.outfit(color: Colors.white30, fontSize: 11)),
                          trailing: IconButton(
                             icon: const Icon(Icons.delete_outline, color: Colors.white30, size: 18),
                             onPressed: () {}, // TODO: delete
                          ),
                        ),
                      )).toList()
                    ],
                  ),
                )
            ]

          ],
        ),
      ),
    );
  }
  
  IconData _getIconForEntity(String? entidad) {
     final e = entidad?.toLowerCase() ?? '';
     if (e.contains('municip')) return Icons.account_balance;
     if (e.contains('mici') || e.contains('comercio')) return Icons.storefront;
     if (e.contains('bomber')) return Icons.local_fire_department;
     if (e.contains('dgi')) return Icons.receipt_long;
     if (e.contains('salud') || e.contains('minsa')) return Icons.health_and_safety;
     return Icons.assignment;
  }

  Widget _buildGlassMetric(IconData icon, String label, String value) {
    return Container(
       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
       decoration: BoxDecoration(
         color: Colors.white.withOpacity(0.03),
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: Colors.white10),
       ),
       child: Column(
         children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value, 
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1, overflow: TextOverflow.ellipsis
            ),
         ],
       ),
    ); 
  }

  Widget _buildQuickActionBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
     return InkWell(
       onTap: onTap,
       borderRadius: BorderRadius.circular(12),
       child: Container(
         padding: const EdgeInsets.symmetric(vertical: 14),
         decoration: BoxDecoration(
           gradient: LinearGradient(
             colors: [ color.withOpacity(0.2), color.withOpacity(0.05) ],
             begin: Alignment.topLeft, end: Alignment.bottomRight
           ),
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: color.withOpacity(0.3)),
         ),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(icon, color: color, size: 18),
             const SizedBox(width: 8),
             Text(label, style: GoogleFonts.outfit(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
           ],
         ),
       ),
     );
  }

  Widget _buildEmptyState() {
     return Container(
       width: double.infinity,
       padding: const EdgeInsets.all(32),
       decoration: BoxDecoration(
         color: Colors.white.withOpacity(0.02),
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.white10),
       ),
       child: Column(
         children: [
            const Icon(Icons.edit_note, size: 40, color: Colors.white24),
            const SizedBox(height: 16),
            Text('Pendiente de completar', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            Text('La información detallada de este trámite está en proceso de carga.', 
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
            ),
         ],
       ),
     );
  }

  Widget _buildChecklistSection(String title, List<String> items, String prefix, {bool isStep = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Icon(isStep ? Icons.format_list_numbered : Icons.checklist, size: 16, color: EmpoderateTheme.goldStrong),
               const SizedBox(width: 8),
               Text(title, style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
             final idx = entry.key;
             final text = entry.value;
             final key = '${prefix}_$idx'; 
             final isChecked = _checkedItems.contains(key);

             return Container(
               margin: const EdgeInsets.only(bottom: 8),
               decoration: BoxDecoration(
                  color: isChecked ? Colors.black26 : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isChecked ? Colors.white10 : Colors.transparent)
               ),
               child: InkWell(
                 onTap: () => _toggleItem(key),
                 borderRadius: BorderRadius.circular(10),
                 child: Padding(
                   padding: const EdgeInsets.all(12),
                   child: Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       AnimatedContainer(
                         duration: const Duration(milliseconds: 200),
                         width: 24, height: 24,
                         margin: const EdgeInsets.only(right: 12, top: 0),
                         decoration: BoxDecoration(
                           color: isChecked ? EmpoderateTheme.goldStrong : Colors.transparent,
                           border: Border.all(color: isChecked ? EmpoderateTheme.goldStrong : Colors.white24, width: 2),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
                       ),
                       Expanded(child: Text(text, style: GoogleFonts.outfit(color: isChecked ? Colors.white38 : Colors.white, fontSize: 14, height: 1.4, decoration: isChecked ? TextDecoration.lineThrough : null))),
                     ],
                   ),
                 ),
               ),
             );
          }).toList()
        ],
      ),
    );
  }

  // _buildLocationCard Removed primarily in favor of Quick Actions
  // But we can keep it if detail.dondeSacar is long text. 
  // For now I replaced it with Quick Actions + Metrics.
  
  Widget _buildTipsSection(List<String> tips) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [ Colors.amber.withOpacity(0.15), Colors.amber.withOpacity(0.05) ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(children: [
             Icon(Icons.lightbulb, color: Colors.amber, size: 20),
             const SizedBox(width: 8),
             Text('CONSEJOS ÚTILES', style: GoogleFonts.outfit(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
           ]),
           const SizedBox(height: 12),
           ...tips.map((tip) => Padding(
             padding: const EdgeInsets.only(bottom: 8),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text('• ', style: TextStyle(color: Colors.amber, fontSize: 16)),
                 Expanded(child: Text(tip, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, height: 1.4))),
               ],
             ),
           )).toList()
        ],
      ),
    );
  }

  Widget _buildSourceSection(TramiteDetail detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
           Icon(Icons.verified_user_outlined, color: Colors.white30, size: 20),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text('FUENTE OFICIAL', style: GoogleFonts.outfit(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                 const SizedBox(height: 4),
                 Text(detail.fuente ?? 'No especificada', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                 if (detail.referencia != null)
                   Text(detail.referencia!, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                 if (detail.fechaVerificacion != null)
                   Padding(
                     padding: const EdgeInsets.only(top: 4),
                     child: Text('Verificado: ${detail.fechaVerificacion}', style: GoogleFonts.outfit(color: Colors.greenAccent.withOpacity(0.5), fontSize: 11)),
                   ),
               ],
             ),
           )
        ],
      ),
    );
  }
}
