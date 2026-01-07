import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/theme/empoderate_theme.dart';

class StatItem {
  final String label;
  final String value;
  final IconData icon;

  const StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class BusinessHeroHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? categoryName; // Optional now
  final IconData icon;
  final Color? color;
  final VoidCallback? onBackPressed; // Optional now
  final List<StatItem>? stats;
  final bool isCompact;

  const BusinessHeroHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.categoryName,
    required this.icon,
    this.color,
    this.onBackPressed,
    this.stats,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? const Color(0xFFD4AF37); // Default Gold
    final double topPadding = isCompact ? 30.0 : 60.0;
    final double bottomPadding = isCompact ? 30.0 : 40.0;
    final double iconSize = isCompact ? 38.0 : 48.0;
    final double iconPadding = isCompact ? 16.0 : 24.0;
    final double titleSize = isCompact ? 24.0 : 32.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding, left: 20, right: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1520),
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=2029&auto=format&fit=crop'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(const Color(0xFF0F1520).withOpacity(0.92), BlendMode.darken),
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
        border: Border(bottom: BorderSide(color: themeColor.withOpacity(0.3))),
      ),
      child: Column(
        children: [
          // Back Button (if provided)
          if (onBackPressed != null)
            Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: onBackPressed,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
                ),
              ),
            ),

          // Main Icon
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF151C2B),
              border: Border.all(color: themeColor.withOpacity(0.5), width: 1.5),
              boxShadow: [
                 BoxShadow(color: themeColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: Icon(icon, size: iconSize, color: themeColor),
          ),
          
          SizedBox(height: isCompact ? 16 : 24),

          // Category (if provided)
          if (categoryName != null) ...[
            Text(
              categoryName!.toUpperCase(),
              style: GoogleFonts.outfit(
                color: themeColor.withOpacity(0.9),
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              height: 1.1,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 15, offset: const Offset(0, 4)),
              ]
            ),
          ),
          
          // Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white60,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],

          // Stats Section
          if (stats != null && stats!.isNotEmpty) ...[
             const SizedBox(height: 32),
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: stats!.map((stat) {
                 return Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   child: Column(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(10),
                         decoration: BoxDecoration(
                           color: themeColor.withOpacity(0.1),
                           shape: BoxShape.circle,
                         ),
                         child: Icon(stat.icon, color: themeColor, size: 20),
                       ),
                       const SizedBox(height: 8),
                       Text(
                         stat.value,
                         style: GoogleFonts.outfit(
                           color: Colors.white,
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                       Text(
                         stat.label,
                         style: GoogleFonts.outfit(
                           color: Colors.white54,
                           fontSize: 11,
                         ),
                       ),
                     ],
                   ),
                 );
               }).toList(),
             )
          ],
        ],
      ),
    );
  }
}
