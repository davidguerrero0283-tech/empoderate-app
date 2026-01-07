import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'neon_widgets.dart'; // For kNeonGold

class PremiumListCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? accentColor;
  final bool showChevron;

  const PremiumListCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.onTap,
    this.accentColor,
    this.showChevron = true,
  }) : super(key: key);

  @override
  State<PremiumListCard> createState() => _PremiumListCardState();
}

class _PremiumListCardState extends State<PremiumListCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Executive Theme Colors
    final Color mainBorder = const Color(0xFFD4AF37).withOpacity(0.18); // Gold subtle
    final Color glassBg = const Color(0xFF151C2B).withOpacity(0.6); // Dark Glass
    final Color activeAccent = widget.accentColor ?? const Color(0xFFD4AF37);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
        scale: _isPressed ? 0.99 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? kNeonGold : (_isPressed ? activeAccent.withOpacity(0.4) : mainBorder),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(color: kNeonGold.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)
              else if (_isPressed)
                BoxShadow(color: activeAccent.withOpacity(0.15), blurRadius: 12)
              else
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 3)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Optional Left Accent Bar
                  if (widget.accentColor != null)
                    Container(
                      width: 4,
                      color: widget.accentColor!.withOpacity(0.8),
                    ),
                  
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Row(
                        children: [
                          if (widget.icon != null) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: activeAccent.withOpacity(0.1),
                              ),
                              child: Icon(widget.icon, color: activeAccent.withOpacity(0.9), size: 22),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.title,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (widget.subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.subtitle!,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white54,
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ]
                              ],
                            ),
                          ),
                          if (widget.showChevron) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.2), size: 14),
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
