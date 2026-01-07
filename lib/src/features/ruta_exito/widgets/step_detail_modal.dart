import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import '../../../components/neon_widgets.dart';
import '../../../navigation/app_routes.dart';
import '../models/ruta_step.dart';

class StepDetailModal extends StatelessWidget {
  final RutaStep step;
  final VoidCallback onToggleComplete;

  const StepDetailModal({
    Key? key,
    required this.step,
    required this.onToggleComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0A0E21),
                const Color(0xFF1A1A2E),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: EmpoderateTheme.goldStrong.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Title
                    Text(
                      step.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      step.description,
                      style: GoogleFonts.outfit(
                        color: EmpoderateTheme.goldStrong,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Content
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        step.content,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tool Link Button (if available)
                    if (step.toolRoute != null)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, step.toolRoute!);
                          },
                          icon: const Icon(Icons.rocket_launch, color: EmpoderateTheme.cyanAccent),
                          label: Text(
                            step.toolLabel ?? 'Ir a Herramienta',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: EmpoderateTheme.cyanAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                    if (step.toolRoute != null) const SizedBox(height: 16),

                    // Mark Complete Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: NeonButton(
                        text: step.isCompleted ? 'Marcar como Pendiente' : 'Marcar como Completado',
                        onTap: () {
                          onToggleComplete();
                          Navigator.pop(context);
                        },
                        primary: !step.isCompleted,
                        color: step.isCompleted ? Colors.white30 : EmpoderateTheme.goldStrong,
                        textColor: step.isCompleted ? Colors.white70 : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Close Button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cerrar',
                        style: GoogleFonts.outfit(color: Colors.white60),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
