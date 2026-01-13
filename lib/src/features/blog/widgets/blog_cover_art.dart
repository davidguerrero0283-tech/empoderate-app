import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BlogCoverArt extends StatelessWidget {
  final String slug;
  final String category;
  final String? title;
  final double? width;
  final double? height;
  final bool isListCard;

  const BlogCoverArt({
    Key? key,
    required this.slug,
    required this.category,
    this.title,
    this.width,
    this.height,
    this.isListCard = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('BLOG: Rendering Cover Art for slug=$slug category=$category');
    final palette = _getPalette(slug);
    final iconData = _getCategoryIcon(category);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background Pattern (Subtle circles)
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              iconData,
              size: isListCard ? 80 : 180,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -10,
            child: Container(
              width: isListCard ? 60 : 120,
              height: isListCard ? 60 : 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  size: isListCard ? 32 : 64,
                  color: Colors.white.withOpacity(0.9),
                ),
                if (!isListCard && title != null) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      title!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getPalette(String key) {
    // Deterministic palette selection based on hash
    final hash = key.codeUnits.fold(0, (previous, current) => previous + current);
    final index = hash % 5;

    switch (index) {
      case 0:
        // Navy & Gold (Classic Empoderate)
        return [const Color(0xFF0D1B2A), const Color(0xFF1B263B)];
      case 1:
        // Deep Blue & Teal
        return [const Color(0xFF001225), const Color(0xFF004D40)]; 
      case 2:
        // Royal Purple & Dark Blue
        return [const Color(0xFF1A237E), const Color(0xFF000000)];
      case 3:
        // Dark Gray & Matte Black
        return [const Color(0xFF263238), const Color(0xFF102027)];
      case 4:
         // Slate & Blue
        return [const Color(0xFF37474F), const Color(0xFF1C2526)];
      default:
        return [const Color(0xFF0D1B2A), const Color(0xFF1B263B)];
    }
  }

  IconData _getCategoryIcon(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('legal') || c.contains('trámite')) return Icons.gavel;
    if (c.contains('finan') || c.contains('dinero') || c.contains('presupuesto')) return Icons.attach_money;
    if (c.contains('market') || c.contains('venta') || c.contains('client')) return Icons.campaign;
    if (c.contains('rrhh') || c.contains('personal') || c.contains('equipo')) return Icons.people_alt;
    if (c.contains('tecno') || c.contains('digital') || c.contains('web')) return Icons.computer;
    return Icons.article_outlined; // Default
  }
}
