import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/blog_article.dart';
import '../widgets/blog_cover_art.dart';

class BlogCard extends StatelessWidget {
  final BlogArticle article;
  final VoidCallback onTap;
  final bool isFeatured;

  const BlogCard({
    Key? key,
    required this.article,
    required this.onTap,
    this.isFeatured = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isFeatured) {
      return _buildFeaturedCard();
    } else {
      return _buildListCard();
    }
  }

  bool _isValidHttpUrl(String? s) {
    if (s == null) return false;
    final v = s.trim();
    if (v.isEmpty) return false;
    return v.startsWith("http://") || v.startsWith("https://");
  }

  Widget _buildFeaturedCard() {
    final validUrl = _isValidHttpUrl(article.imageUrl);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background Image or Cover Art
              if (validUrl)
                Image.network(
                  article.imageUrl.trim(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('BLOG: Error loading image for ${article.title}: $error');
                    return _buildCoverArt(isList: false);
                  },
                )
              else
                _buildCoverArt(isList: false),

              // 2. Gradient Overlay (Scrim) - Only if using image
              if (validUrl)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

              // 3. Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF001225).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        article.category.toUpperCase(),
                        style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white, 
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.subtitle,
                      style: GoogleFonts.outfit(
                        color: Colors.white70, 
                        fontSize: 12,
                        shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard() {
    final validUrl = _isValidHttpUrl(article.imageUrl);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF151C2B), // Premium matte dark
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)), // Subtle border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Section
            Container(
              width: 110,
              height: 110,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                child: validUrl
                    ? Image.network(
                        article.imageUrl.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                           print('BLOG: Error loading list image for ${article.title}: $error');
                           return _buildCoverArt(isList: true);
                        },
                      )
                    : _buildCoverArt(isList: true),
              ),
            ),
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                          ),
                          child: Text(
                            article.category.toUpperCase(),
                            style: GoogleFonts.outfit(color: const Color(0xFFD4AF37), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '${article.readTime.ceil()} min',
                          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.description,
                      style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverArt({required bool isList}) {
    return BlogCoverArt(
      slug: article.id,
      category: article.category,
      title: isList ? null : article.title, // Only show title on featured if desired, logic allows it
      isListCard: isList,
    );
  }
}
