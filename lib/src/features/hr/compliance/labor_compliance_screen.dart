
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';

import '../../../data/repositories/checklist_repository.dart';
import '../payroll/payroll_obligation_model.dart';
import '../payroll/payroll_obligations_repository.dart';
import 'package:proyecto_empoderate/src/widgets/feature_intro_screen.dart';

class LaborComplianceScreen extends StatefulWidget {
  const LaborComplianceScreen({Key? key}) : super(key: key);

  @override
  State<LaborComplianceScreen> createState() => _LaborComplianceScreenState();
}

class _LaborComplianceScreenState extends State<LaborComplianceScreen> {
  final _repo = PayrollObligationsRepository();
  List<PayrollObligation> _obligations = [];
  bool _loading = true;
  
  // Format dates
  final DateFormat _monthFormat = DateFormat('MMMM yyyy', 'es_ES');
  DateTime _currentDate = DateTime.now();

  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await _repo.getMonth(_currentDate.year, _currentDate.month);
    
    // Sort: Pending first, then alphabetic
    data.sort((a, b) {
      if (a.isDone && !b.isDone) return 1;
      if (!a.isDone && b.isDone) return -1;
      return a.title.compareTo(b.title);
    });

    if (mounted) {
      setState(() {
        _obligations = data;
        _loading = false;
      });
    }
  }

  Future<void> _toggleDone(PayrollObligation ob) async {
    await _repo.toggleDone(_currentDate.year, _currentDate.month, ob.id);
    await ChecklistRepository().refresh();
    _loadData();
  }

  Future<void> _delete(PayrollObligation ob) async {
    await _repo.deleteObligation(_currentDate.year, _currentDate.month, ob.id);
    await ChecklistRepository().refresh();
    _loadData();
  }

  Future<void> _addObligation(String title, String? desc) async {
    final newOb = PayrollObligation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: desc,
      createdAt: DateTime.now(),
      isDone: false,
    );
    await _repo.addObligation(_currentDate.year, _currentDate.month, newOb);
    await ChecklistRepository().refresh();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // Calc stats
    final total = _obligations.length;
    final done = _obligations.where((o) => o.isDone).length;
    final percent = total == 0 ? 0.0 : (done / total);

    return PremiumScaffold(
      title: 'Cumplimiento Laboral',
      showBackButton: true,
      useScroll: false, // We handle scrolling manually with Stack
      usePadding: false,
      body: Stack(
        children: [
          // MAIN CONTENT - wrapped in Positioned.fill for proper layout
          Positioned.fill(
            child: _loading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FECHA
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Text(
                            _monthFormat.format(_currentDate).toUpperCase(),
                            style: GoogleFonts.outfit(color: Colors.white70, letterSpacing: 1),
                          ),
                        ),
                      ),
    
                      // 1. MONTH SUMMARY
                      _buildMonthSummary(done, total, percent),
                      const SizedBox(height: 24),
    
                      // 2. GUIDE (Always Visible)
                      _buildGuideCard(),
                      const SizedBox(height: 24),
    
                      // 3. EDITABLE LIST
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tus Obligaciones', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Color(0xFFD4AF37), size: 28),
                            onPressed: () => _showAddModal(context),
                            tooltip: 'Agregar nueva',
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      if (_obligations.isEmpty)
                        _buildEmptyState()
                      else
                        ..._obligations.map((ob) => _buildObligationItem(ob)).toList(),
                        
                        
                      ],
                    ),
                  ),
          ),
          
          // INTRO OVERLAY - wrapped in Positioned.fill for proper layout
          if (_showIntro)
            Positioned.fill(
              child: FeatureIntroScreen(
                key: const ValueKey('IntroOverlay'),
                title: 'CUMPLIMIENTO TOTAL',
                subTitle: 'Monitorea tus obligaciones patronales y evita multas. SIPE, DGI y Municipio bajo control.',
                heroEmoji: '⚖️',
                primaryColor: const Color(0xFF29B6F6), // Light Blue
                features: const [
                   IntroFeatureItem(Icons.event_available, 'Calendario Fiscal'),
                   IntroFeatureItem(Icons.rule, 'Normativa'),
                   IntroFeatureItem(Icons.notifications_active, 'Alertas'),
                ],
                processSteps: const [
                   IntroStepItem('1. Revisa', 'Consulta obligaciones.'),
                   IntroStepItem('2. Ejecuta', 'Realiza pagos.'),
                   IntroStepItem('3. Marca', 'Haz check.'),
                   IntroStepItem('4. Cumple', 'Sin recargos.'),
                ],
                proTip: 'Las fechas de la CSS y DGI son estrictas.',
                onDismiss: () => setState(() => _showIntro = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(int done, int total, double percent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF003366), Color(0xFF001B3A)]), // Deep Blue
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progreso del Mes', style: GoogleFonts.outfit(color: Colors.white70)),
              Text('$done / $total', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white10,
              color: const Color(0xFF00E5FF), // Cyan
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          if (total == 0)
             Text(
               'Sin configurar. Agrega obligaciones para comenzar.',
               style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
             )
          else if (percent == 1.0)
             Text(
               '¡Excelente! Todo al día.',
               style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold),
             )
          else
             Text(
               'Completa las tareas pendientes.',
               style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
             ),
        ],
      ),
    );
  }

  Widget _buildGuideCard() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        collapsedBackgroundColor: const Color(0xFF1E1E1E),
        backgroundColor: const Color(0xFF1E1E1E),
        iconColor: const Color(0xFFD4AF37),
        collapsedIconColor: Colors.white54,
        textColor: const Color(0xFFD4AF37),
        collapsedTextColor: Colors.white,
        maintainState: true,
        initiallyExpanded: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white10)),
        
        leading: const Icon(Icons.library_books_outlined),
        title: Text('Guía de Obligaciones', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text('¿Qué debo presentar este mes?', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
        
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuidePoint('1. Planilla Mensual', 'Se debe tener lista antes del cierre (15 y 30).'),
                const SizedBox(height: 8),
                _buildGuidePoint('2. SIPE (CSS)', 'El pago vence a fin de mes. Genera el recibo a tiemo.'),
                const SizedBox(height: 8),
                _buildGuidePoint('3. Municipales', 'Impuestos municipales vencen usualmente el 15.'),
                const SizedBox(height: 16),
                NeonButton(
                  text: 'Ver Guía Completa',
                  color: Colors.white, // Border style
                  textColor: Colors.white,
                  onTap: () {
                     // Could navigate to blog or expanded guide logic
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abriendo guía detallada...')));
                  }, 
                  // Outline style simulation with NeonButton usually solid, but let's use standard config
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGuidePoint(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              children: [
                TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                TextSpan(text: desc)
              ]
            ),
          ),
        )
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Icon(Icons.assignment_add, size: 48, color: Colors.white10),
            const SizedBox(height: 12),
            Text(
              "No tienes obligaciones registradas",
              style: GoogleFonts.outfit(color: Colors.white30),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
              child: const Text('Agregar Obligación'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildObligationItem(PayrollObligation item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.withOpacity(0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _delete(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF131313),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.isDone ? Colors.green.withOpacity(0.3) : Colors.white10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Checkbox(
            value: item.isDone,
            activeColor: const Color(0xFFD4AF37),
            onChanged: (val) => _toggleDone(item),
          ),
          title: Text(
            item.title,
            style: GoogleFonts.outfit(
              color: item.isDone ? Colors.white38 : Colors.white,
              decoration: item.isDone ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: item.description != null && item.description!.isNotEmpty 
              ? Text(item.description!, style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12)) 
              : null,
          trailing: item.isDone 
              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
              : null,
        ),
      ),
    );
  }

  void _showAddModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F0F1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, 
          left: 20, right: 20, top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nueva Obligación', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Título (Ej. SIPE, Planilla)',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Descripción / Nota (Opcional)',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  _addObligation(titleCtrl.text.trim(), descCtrl.text.trim());
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('GUARDAR'),
            )
          ],
        ),
      ),
    );
  }
}
