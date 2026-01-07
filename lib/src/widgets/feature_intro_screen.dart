import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureIntroScreen extends StatefulWidget {
  final String title;
  final String subTitle;
  final String heroEmoji; // e.g. "📅" or "👥"
  final List<IntroFeatureItem> features;
  final List<IntroStepItem> processSteps;
  final String proTip;
  final Color primaryColor;
  final VoidCallback onDismiss;

  const FeatureIntroScreen({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.heroEmoji,
    required this.features,
    required this.processSteps,
    required this.proTip,
    this.primaryColor = Colors.cyanAccent,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<FeatureIntroScreen> createState() => _FeatureIntroScreenState();
}

class _FeatureIntroScreenState extends State<FeatureIntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Material(
        type: MaterialType.transparency, // Allows underlying screen to be seen if we use opacity
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0A0F), // Very dark base - fully opaque
                Color.lerp(const Color(0xFF0A0A0F), widget.primaryColor, 0.15)!, // Subtle card color - fully opaque blend
                const Color(0xFF0F0F1A), // Dark - fully opaque
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Background Pattern (Subtle)
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.primaryColor.withOpacity(0.05),
                    boxShadow: [BoxShadow(color: widget.primaryColor.withOpacity(0.1), blurRadius: 100, spreadRadius: 50)],
                  ),
                ),
              ),

              // Content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // HERO SECTION
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: widget.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: widget.primaryColor.withOpacity(0.3), width: 2),
                                boxShadow: [BoxShadow(color: widget.primaryColor.withOpacity(0.2), blurRadius: 20)],
                              ),
                              child: Text(widget.heroEmoji, style: const TextStyle(fontSize: 48)),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.subTitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // FEATURES GRID
                            Text('HERRAMIENTAS INCLUIDAS', style: GoogleFonts.outfit(color: widget.primaryColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: widget.features.map((f) => _buildFeatureCard(f)).toList(),
                            ),
                            const SizedBox(height: 40),

                            // PROCESS TIMELINE
                            Text('FLUJO DE TRABAJO', style: GoogleFonts.outfit(color: widget.primaryColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Column(
                                children: widget.processSteps.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final step = entry.value;
                                  final isLast = index == widget.processSteps.length - 1;
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: widget.primaryColor.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: widget.primaryColor),
                                            ),
                                            child: Center(child: Text('${index + 1}', style: TextStyle(color: widget.primaryColor, fontSize: 12, fontWeight: FontWeight.bold))),
                                          ),
                                          if (!isLast)
                                            Container(
                                              width: 2,
                                              height: 40,
                                              color: widget.primaryColor.withOpacity(0.3),
                                              margin: const EdgeInsets.symmetric(vertical: 4),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(step.title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                            const SizedBox(height: 2),
                                            Text(step.description, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                                            const SizedBox(height: 24),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            
                            const SizedBox(height: 30),

                            // PRO TIP
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.outfit(color: Colors.amber.shade100, fontSize: 12),
                                        children: [
                                          const TextSpan(text: 'TIP PRO: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                                          TextSpan(text: widget.proTip),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // DISMISS HINT
                            Text(
                              'Toca cualquier parte para comenzar',
                              style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.white30, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IntroFeatureItem item) {
    return Container(
      width: 100, // Fixed width for uniformity in Wrap
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(item.icon, color: widget.primaryColor, size: 24),
          const SizedBox(height: 8),
          Text(item.label, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class IntroFeatureItem {
  final IconData icon;
  final String label;
  const IntroFeatureItem(this.icon, this.label);
}

class IntroStepItem {
  final String title;
  final String description;
  const IntroStepItem(this.title, this.description);
}
