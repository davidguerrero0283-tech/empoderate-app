import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import '../services/tutorial_service.dart';

/// Widget overlay que muestra tutoriales interactivos paso a paso.
/// Incluye backdrop oscuro, spotlight en elementos target, y tooltips animados.
class TutorialOverlay extends StatefulWidget {
  final TutorialConfig config;
  final VoidCallback onComplete;

  const TutorialOverlay({
    Key? key,
    required this.config,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animController);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.config.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animController.reset();
      _animController.forward();
    } else {
      _completeTutorial();
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  void _neverShowAgain() {
    TutorialService.instance.markTutorialSeen(widget.config.screenKey);
    widget.onComplete();
  }

  void _completeTutorial() {
    TutorialService.instance.markTutorialSeen(widget.config.screenKey);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.config.steps[_currentStep];
    final totalSteps = widget.config.steps.length;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop oscuro con blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                color: Colors.black.withOpacity(0.75),
              ),
            ),
          ),

          // Spotlight en target (si existe)
          if (step.targetKey != null)
            _buildSpotlight(step.targetKey!),

          // Tooltip card
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildTooltip(step, _currentStep + 1, totalSteps),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlight(GlobalKey targetKey) {
    // Intentar obtener el RenderBox del target
    try {
      final RenderBox? renderBox =
          targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return const SizedBox.shrink();

      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      return Positioned(
        left: position.dx - 8,
        top: position.dy - 8,
        child: Container(
          width: size.width + 16,
          height: size.height + 16,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD4AF37),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildTooltip(TutorialStep step, int currentNum, int total) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF001B3A),
              Color(0xFF003366),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4AF37),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon + Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step.icon,
                    color: const Color(0xFFD4AF37),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    step.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              step.description,
              style: GoogleFonts.roboto(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                total,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == currentNum - 1 ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == currentNum - 1
                        ? const Color(0xFFD4AF37)
                        : Colors.white30,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Paso $currentNum de $total',
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                TextButton(
                  onPressed: _skipTutorial,
                  child: Text(
                    'Saltar',
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_currentStep == 0)
                  TextButton(
                    onPressed: _neverShowAgain,
                    child: Text(
                      'No volver a mostrar',
                      style: GoogleFonts.outfit(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF001B3A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentNum == total ? 'Finalizar' : 'Siguiente',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (currentNum < total) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper para mostrar el tutorial en un overlay
class TutorialHelper {
  static OverlayEntry? _currentOverlay;

  /// Muestra el tutorial para una pantalla si no se ha visto antes.
  static Future<void> showIfNeeded(
    BuildContext context,
    String screenKey,
  ) async {
    // Verificar si los tutoriales están habilitados
    final enabled = await TutorialService.instance.areTutorialsEnabled();
    if (!enabled) return;

    // Verificar si ya se vio este tutorial
    final seen = await TutorialService.instance.hasSeenTutorial(screenKey);
    if (seen) return;

    // Obtener configuración
    final config = TutorialService.instance.getTutorialConfig(screenKey);
    if (config == null) return;

    // Mostrar tutorial
    show(context, config);
  }

  /// Muestra el tutorial manualmente.
  static void show(BuildContext context, TutorialConfig config) {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }

    _currentOverlay = OverlayEntry(
      builder: (context) => TutorialOverlay(
        config: config,
        onComplete: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  /// Cierra el tutorial actual si existe.
  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}
