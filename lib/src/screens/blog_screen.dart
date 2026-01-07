import 'package:flutter/material.dart';
import 'package:proyecto_empoderate/ui/components/header/premium_header.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Blog y Actualizaciones',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mantente informado con lo último para emprendedores',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),

          _buildBlogPostPlaceholder(context),
          const SizedBox(height: 16),
          _buildBlogPostPlaceholder(context),
          const SizedBox(height: 16),
          _buildBlogPostPlaceholder(context),

          const SizedBox(height: 32),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                'Pronto verás contenido educativo aquí.',
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogPostPlaceholder(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF001220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image, color: Colors.white24, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.1),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 150,
                  color: Colors.white.withOpacity(0.05),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
