import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../ui/theme/empoderate_theme.dart';
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import 'models/ruta_step.dart';
import 'data/ruta_content.dart';
import 'widgets/step_detail_modal.dart';

class RutaExitoScreen extends StatefulWidget {
  const RutaExitoScreen({Key? key}) : super(key: key);

  @override
  State<RutaExitoScreen> createState() => _RutaExitoScreenState();
}

class _RutaExitoScreenState extends State<RutaExitoScreen> {
  List<RutaPhase> _phases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completedIds = prefs.getStringList('ruta_completed_steps') ?? [];
    
    setState(() {
      _phases = rutaPhases.map((phase) {
        return RutaPhase(
          id: phase.id,
          title: phase.title,
          subtitle: phase.subtitle,
          color: phase.color,
          steps: phase.steps.map((step) {
            return RutaStep(
              id: step.id,
              title: step.title,
              description: step.description,
              content: step.content,
              toolRoute: step.toolRoute,
              toolLabel: step.toolLabel,
              isCompleted: completedIds.contains(step.id.toString()),
            );
          }).toList(),
        );
      }).toList();
      _isLoading = false;
    });
  }

  Future<void> _toggleStepCompletion(RutaStep step) async {
    final prefs = await SharedPreferences.getInstance();
    final completedIds = prefs.getStringList('ruta_completed_steps') ?? [];
    
    setState(() {
      step.isCompleted = !step.isCompleted;
    });

    if (step.isCompleted) {
      completedIds.add(step.id.toString());
    } else {
      completedIds.remove(step.id.toString());
    }
    
    await prefs.setStringList('ruta_completed_steps', completedIds);
  }

  void _openStepDetail(RutaStep step) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StepDetailModal(
        step: step,
        onToggleComplete: () => _toggleStepCompletion(step),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E21),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalSteps = _phases.fold<int>(0, (sum, phase) => sum + phase.totalCount);
    final completedSteps = _phases.fold<int>(0, (sum, phase) => sum + phase.completedCount);
    final overallProgress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return PremiumScaffold(
      title: 'RUTA DEL ÉXITO',
      showBackButton: true,
      useScroll: true,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Progress Card
            NeonCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso General',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedSteps / $totalSteps',
                        style: GoogleFonts.outfit(
                          color: EmpoderateTheme.goldStrong,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: overallProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(EmpoderateTheme.goldStrong),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(overallProgress * 100).toStringAsFixed(0)}% completado',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Phases
            ..._phases.map((phase) => _buildPhaseCard(phase)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseCard(RutaPhase phase) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeonCard(
        padding: const EdgeInsets.all(0),
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            childrenPadding: const EdgeInsets.only(bottom: 16),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(phase.color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(phase.color)),
              ),
              child: Center(
                child: Text(
                  '${phase.id}',
                  style: GoogleFonts.outfit(
                    color: Color(phase.color),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              phase.title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  phase.subtitle,
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: phase.progress,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(phase.color)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${phase.completedCount}/${phase.totalCount} pasos completados',
                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
            children: phase.steps.map((step) => _buildStepTile(step, phase)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStepTile(RutaStep step, RutaPhase phase) {
    return ListTile(
      onTap: () => _openStepDetail(step),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        step.isCompleted ? Icons.check_circle : Icons.circle_outlined,
        color: step.isCompleted ? Color(phase.color) : Colors.white30,
        size: 24,
      ),
      title: Text(
        step.title,
        style: GoogleFonts.outfit(
          color: step.isCompleted ? Colors.white70 : Colors.white,
          fontSize: 15,
          decoration: step.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        step.description,
        style: GoogleFonts.outfit(
          color: Colors.white60,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.white30,
        size: 16,
      ),
    );
  }
}
