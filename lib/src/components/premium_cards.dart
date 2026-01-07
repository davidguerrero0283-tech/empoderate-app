import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'neon_widgets.dart'; // For kNeonGold

// STYLE A: Premium Transparent Card (For generic lists, tools, options)
class ComponenteTarjetaPremium extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool compact;

  const ComponenteTarjetaPremium({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.compact = false,
  }) : super(key: key);

  @override
  State<ComponenteTarjetaPremium> createState() => _ComponenteTarjetaPremiumState();
}

class _ComponenteTarjetaPremiumState extends State<ComponenteTarjetaPremium> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Style from ProfileOptionCard / ProfileScreen generic cards
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: widget.compact ? 12 : 16),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? kNeonGold : Colors.white10,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: kNeonGold.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (widget.iconColor ?? const Color(0xFFD4AF37)).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor ?? const Color(0xFFD4AF37),
                  size: widget.compact ? 22 : 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: widget.compact ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: widget.compact ? 11 : 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow
              const Icon(Icons.chevron_right, color: Colors.white24, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}


// STYLE B: Main Phase Card (For main sections, phases, primary categories)
class ComponenteTarjetaPrincipal extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool showProgress;
  
  const ComponenteTarjetaPrincipal({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.showProgress = false,
  }) : super(key: key);

  @override
  State<ComponenteTarjetaPrincipal> createState() => _ComponenteTarjetaPrincipalState();
}

class _ComponenteTarjetaPrincipalState extends State<ComponenteTarjetaPrincipal> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 120,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? kNeonGold : widget.color.withOpacity(0.5),
              width: _isHovered ? 2 : 1.5,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: kNeonGold.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              else
                BoxShadow(
                  color: widget.color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              // Left Color Strip
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Large Icon
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.color.withOpacity(0.3)),
                ),
                child: Icon(widget.icon, color: widget.color, size: 32),
              ),
              const SizedBox(width: 20),
              // Texts
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Chevron
              const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
