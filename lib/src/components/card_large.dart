import 'package:flutter/material.dart';
import 'neon_widgets.dart'; // For kNeonGold

class CardLarge extends StatefulWidget {
  final Widget child;
  const CardLarge({Key? key, required this.child}) : super(key: key);

  @override
  State<CardLarge> createState() => _CardLargeState();
}

class _CardLargeState extends State<CardLarge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF001220).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? kNeonGold : const Color(0xFFD4AF37).withOpacity(0.5),
            width: _isHovered ? 2 : 1.0,
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
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
