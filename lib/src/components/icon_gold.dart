import 'package:flutter/material.dart';

class IconGold extends StatelessWidget {
  final IconData icon;
  final double size;
  const IconGold({Key? key, required this.icon, this.size = 24}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: const Color(0xFFD4AF37), // intense gold
      size: size,
    );
  }
}
