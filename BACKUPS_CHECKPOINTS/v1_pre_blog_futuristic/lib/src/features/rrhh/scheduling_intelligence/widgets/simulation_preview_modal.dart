import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/services/schedule_simulation_service.dart';
import 'package:proyecto_empoderate/src/features/rrhh/scheduling_intelligence/models/constraint_result.dart';

class SimulationPreviewModal extends StatelessWidget {
  final SimulationResult result;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const SimulationPreviewModal({
    Key? key,
    required this.result,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine status color
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;
    String statusTitle = 'Cambio Seguro';
    
    if (!result.isViable) {
      statusColor = Colors.redAccent;
      statusIcon = Icons.warning;
      statusTitle = 'Violación de Reglas';
    } else if (result.scoreDelta < -5) {
      statusColor = Colors.orangeAccent;
      statusIcon = Icons.info;
      statusTitle = 'Reduce Eficiencia';
    }

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      title: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 8),
          Text(statusTitle, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Impact
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Impacto en Salud del Horario', style: TextStyle(color: Colors.white70)),
                  Row(
                    children: [
                      Icon(
                        result.scoreDelta >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        color: result.scoreDelta >= 0 ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      Text(
                        ' ${result.scoreDelta.toStringAsFixed(1)} pts',
                        style: TextStyle(
                          color: result.scoreDelta >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Violations List
            if (result.violations.isNotEmpty) ...[
              const Text('Alertas Detectadas:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...result.violations.map((v) => _buildViolationCard(v)).toList(),
            ] else 
              const Text('✅ No se detectaron conflictos con las reglas.', style: TextStyle(color: Colors.greenAccent)),

          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: result.isViable ? Colors.green : Colors.redAccent,
          ),
          onPressed: result.isViable ? onConfirm : null, // Disable if hard violation? Or allow override?
          // For now, disable on hard violation
          child: Text(result.isViable ? 'Aprobar Cambio' : 'Bloqueado', style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildViolationCard(ConstraintResult violation) {
    final isHard = violation.type == ConstraintType.hard;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHard ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        border: Border.all(color: isHard ? Colors.redAccent : Colors.orangeAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isHard ? Icons.block : Icons.warning_amber, color: isHard ? Colors.redAccent : Colors.orangeAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  violation.description,
                  style: TextStyle(color: isHard ? Colors.redAccent : Colors.orangeAccent, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Regla: ${violation.ruleId}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
