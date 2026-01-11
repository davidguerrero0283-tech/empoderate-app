import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../services/compliance_checklist_service.dart';
import '../../../../ui/theme/empoderate_theme.dart';

/// Compact progress card for HOME screen showing compliance checklist progress.
/// Does NOT modify home_locked - this is a separate widget.
class HomeComplianceProgressCard extends StatefulWidget {
  const HomeComplianceProgressCard({super.key});

  @override
  State<HomeComplianceProgressCard> createState() => _HomeComplianceProgressCardState();
}

class _HomeComplianceProgressCardState extends State<HomeComplianceProgressCard> {
  final ComplianceChecklistService _service = ComplianceChecklistService();
  ComplianceProgress? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _service.getProgress();
    if (mounted) {
      setState(() {
        _progress = progress;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/hr/compliance_checklist'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF4081).withOpacity(0.12),
              const Color(0xFFFF4081).withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF4081).withOpacity(0.4)),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4081).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.checklist, color: Color(0xFFFF4081), size: 24),
                  ),
                  const SizedBox(width: 14),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cumplimiento Laboral',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_progress?.completed ?? 0}/${_progress?.total ?? 0} tareas completadas',
                          style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progress?.percent ?? 0.0,
                            minHeight: 6,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              (_progress?.percent ?? 0) >= 1.0
                                  ? Colors.greenAccent
                                  : const Color(0xFFFF4081),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Percentage
                  Column(
                    children: [
                      Text(
                        '${((_progress?.percent ?? 0) * 100).toInt()}%',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFF4081),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Color(0xFFFF4081), size: 12),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
