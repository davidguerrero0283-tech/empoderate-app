import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumNegocioSectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const PremiumNegocioSectionHeader({
    Key? key,
    required this.title,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 3, height: 20, color: color.withOpacity(0.8)),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18, 
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.95), 
            ),
          ),
        ],
      ),
    );
  }
}
