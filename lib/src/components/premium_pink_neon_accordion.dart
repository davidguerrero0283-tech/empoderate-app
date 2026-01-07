import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';

class PremiumPinkNeonAccordion extends StatefulWidget {
  final String title;
  final Widget content;

  const PremiumPinkNeonAccordion({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  State<PremiumPinkNeonAccordion> createState() => _PremiumPinkNeonAccordionState();
}

class _PremiumPinkNeonAccordionState extends State<PremiumPinkNeonAccordion> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Colors - Switched to Premium Gold Gradient (Punch Style)
    final neonBorder = EmpoderateTheme.goldStrong;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        // Solid Gold Gradient as requested ("Empezar-like")
        gradient: EmpoderateTheme.gradientGold,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.4), // Subtle inner rim
          width: 1.0
        ),
        boxShadow: [
          BoxShadow(
            color: EmpoderateTheme.goldStrong.withOpacity(0.4),
            blurRadius: 10, // Distinct Gold Glow
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // HEADER (Always visible)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        // High Contrast: Black Text on Gold
                        color: Colors.black, 
                        fontWeight: FontWeight.bold,
                        fontSize: 15, // Slightly larger
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          
          // CONTENT (Collapsible)
          AnimatedCrossFade(
            firstChild: Container(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 12),
                  DefaultTextStyle(
                    style: GoogleFonts.outfit(color: const Color(0xFF0F1520).withOpacity(0.9), fontSize: 13, height: 1.5),
                    child: widget.content, // Content passed from parent
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
