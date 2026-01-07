import 'package:flutter/material.dart';
import 'package:proyecto_empoderate/ui/theme/color_palette.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({
    Key? key, 
    required this.child,
    this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors ?? [
            AppColors.background,
            AppColors.backgroundAlt,
          ],
        ),
      ),
      child: child, // Ensure safe area is handled by parent or child
    );
  }
}

