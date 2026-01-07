
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/neon_widgets.dart';
import '../navigation/app_routes.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                   color: Colors.redAccent.withOpacity(0.1),
                   shape: BoxShape.circle,
                   border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.redAccent.withOpacity(0.2),
                       blurRadius: 20,
                       spreadRadius: 5
                     )
                   ]
                ),
                child: const Icon(Icons.lock_outline, size: 64, color: Colors.redAccent),
              ),
              const SizedBox(height: 32),
              
              // Text
              Text(
                '404',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 64, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Página no encontrada',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Parece que esta sección no existe o no tienes permisos para verla.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),

              // Button
              SizedBox(
                width: 200,
                child: NeonButton(
                  text: 'Volver al Inicio',
                  onTap: () => context.go(AppRoutes.root),
                  color: Colors.redAccent,
                  primary: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
