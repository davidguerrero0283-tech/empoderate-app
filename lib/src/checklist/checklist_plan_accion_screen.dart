import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/components/header/premium_header.dart';
import '../components/gradient_background.dart';
import 'checklist_models.dart';
import 'checklist_service_placeholder.dart';
import 'checklist_components.dart';

class ChecklistPlanAccionScreen extends StatefulWidget {
  const ChecklistPlanAccionScreen({Key? key}) : super(key: key);

  @override
  State<ChecklistPlanAccionScreen> createState() => _ChecklistPlanAccionScreenState();
}

class _ChecklistPlanAccionScreenState extends State<ChecklistPlanAccionScreen> {
  final ChecklistServicePlaceholder _service = ChecklistServicePlaceholder();
  late List<PlanAccionItem> _items;

  @override
  void initState() {
    super.initState();
    _items = _service.getPlanAccionBase('placeholder_id');
  }

  @override
  Widget build(BuildContext context) {
    final highPriority = _items.where((i) => i.priority == 1).toList();
    final mediumPriority = _items.where((i) => i.priority == 2).toList();
    final lowPriority = _items.where((i) => i.priority == 3).toList();

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: PremiumHeader(showBackButton: true),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan de acción del negocio',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Completa estas tareas clave para avanzar con seguridad.',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              if (highPriority.isNotEmpty) ...[
                _buildSectionTitle('Alta prioridad'),
                ...highPriority.map((item) => PlanAccionItemTile(
                      item: item,
                      onChanged: (val) => setState(() => item.isCompleted = val),
                    )),
                const SizedBox(height: 16),
              ],
              if (mediumPriority.isNotEmpty) ...[
                _buildSectionTitle('Prioridad media'),
                ...mediumPriority.map((item) => PlanAccionItemTile(
                      item: item,
                      onChanged: (val) => setState(() => item.isCompleted = val),
                    )),
                const SizedBox(height: 16),
              ],
              if (lowPriority.isNotEmpty) ...[
                _buildSectionTitle('Prioridad baja'),
                ...lowPriority.map((item) => PlanAccionItemTile(
                      item: item,
                      onChanged: (val) => setState(() => item.isCompleted = val),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: const Color(0xFFD4AF37),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
