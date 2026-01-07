import 'package:flutter/material.dart';
import 'neon_widgets.dart'; // For kNeonGold

class CardSmall extends StatefulWidget {
  final Widget child;
  const CardSmall({Key? key, required this.child}) : super(key: key);

  @override
  State<CardSmall> createState() => _CardSmallState();
}

class _CardSmallState extends State<CardSmall> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? kNeonGold : const Color(0xFFD4AF37),
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
                color: Colors.black45,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
