import 'package:flutter/material.dart';

class DividerGold extends StatelessWidget {
  final double thickness;
  const DividerGold({Key? key, this.thickness = 1.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: const Color(0xFFD4AF37),
      thickness: thickness,
    );
  }
}
