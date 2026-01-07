import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';

class PremiumNegocioListCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? accentColor;
  final bool showChevron;
  final VoidCallback? onChevronTap;
  
  // New Enhanced Props
  final List<String> tags; // e.g. ["POPULAR", "BAJA INVERSIÓN"]
  final String? investmentLevel; // e.g. "$$"
  final String? timeEstimate; // e.g. "1 Mes"

  const PremiumNegocioListCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.onTap,
    this.accentColor,
    this.showChevron = true,
    this.onChevronTap,
    this.tags = const [],
    this.investmentLevel,
    this.timeEstimate,
  }) : super(key: key);

  @override
  State<PremiumNegocioListCard> createState() => _PremiumNegocioListCardState();
}

class _PremiumNegocioListCardState extends State<PremiumNegocioListCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Colors
    final Color activeAccent = widget.accentColor ?? const Color(0xFFD4AF37);
    final bool isHighValue = widget.investmentLevel == '\$\$\$';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : (_isHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: EmpoderateTheme.safeBoxDecoration(
               gradient: LinearGradient(
                 colors: [
                   const Color(0xFF1E2532).withOpacity(0.8), 
                   const Color(0xFF151C2B).withOpacity(0.6), 
                 ],
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
               ),
               borderRadius: BorderRadius.circular(20),
               boxShadow: [
                 BoxShadow(
                   color: activeAccent.withOpacity(_isHovered ? 0.15 : 0.05),
                   blurRadius: _isHovered ? 20 : 10,
                   spreadRadius: _isHovered ? 2 : 0,
                 )
               ],
               border: Border.all(
                 color: _isHovered 
                     ? activeAccent.withOpacity(0.6) 
                     : EmpoderateTheme.goldStrong.withOpacity(0.3),
                 width: _isHovered ? 1.5 : 1.0, 
               ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // 1. Background Watermark Icon (Dynamic Background)
                  if (widget.icon != null)
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Icon(
                          widget.icon,
                          size: 140,
                          color: activeAccent.withOpacity(0.05),
                        ),
                      ),
                    ),

                  // 2. Glass Shine Effect (Top)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Main Content Layout
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon Box
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: EmpoderateTheme.circle(
                                 color: Colors.black26,
                                 border: Border.all(
                                  color: activeAccent.withOpacity(0.4),
                                  width: 1.0,
                                 ),
                                 boxShadow: [
                                    BoxShadow(color: activeAccent.withOpacity(0.1), blurRadius: 8)
                                 ],
                              ),
                              child: Icon(widget.icon, color: activeAccent, size: 24),
                            ),
                            const SizedBox(width: 16),
                            
                            // Text Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title + Tags Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.title,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (widget.subtitle != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.subtitle!,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white60,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            
                            // Chevron (if enabled)
                            if (widget.showChevron)
                              Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                          ],
                        ),
                        
                        // 4. Tags & Stats Divider
                        if (widget.tags.isNotEmpty || widget.investmentLevel != null) ...[
                          const SizedBox(height: 16),
                          Divider(color: Colors.white.withOpacity(0.05), height: 1),
                          const SizedBox(height: 12),
                        ],

                        // 5. Bottom Row: Tags & Stats
                        Row(
                          children: [
                            // Tags
                            ...widget.tags.map((tag) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: tag == 'POPULAR' 
                                    ? Colors.purpleAccent.withOpacity(0.2) 
                                    : (tag == 'NUEVO' ? Colors.greenAccent.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: tag == 'POPULAR' 
                                      ? Colors.purpleAccent.withOpacity(0.4) 
                                      : (tag == 'NUEVO' ? Colors.greenAccent.withOpacity(0.4) : Colors.blueAccent.withOpacity(0.4)),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            )).toList(),

                            const Spacer(),

                            // Investment Level
                            if (widget.investmentLevel != null) ...[
                              Icon(Icons.monetization_on, color: Colors.white38, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                widget.investmentLevel!,
                                style: GoogleFonts.outfit(
                                  color: isHighValue ? Colors.amberAccent : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],

                            // Time Estimate
                            if (widget.timeEstimate != null) ...[
                              Icon(Icons.timer, color: Colors.white38, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                widget.timeEstimate!,
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
