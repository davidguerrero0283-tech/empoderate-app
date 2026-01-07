import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'BIENVENIDO',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.person_add_alt_1_outlined, color: EmpoderateTheme.goldStrong, size: 60),
            const SizedBox(height: 24),
            Text(
              'Únete a Empodérate',
              style: EmpoderateTheme.titleStyle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu cuenta para guardar tu progreso.',
              style: EmpoderateTheme.subtitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            _buildTextField('Nombre Completo'),
            const SizedBox(height: 16),
            _buildTextField('Correo Electrónico'),
            const SizedBox(height: 16),
            _buildTextField('Contraseña', obscureText: true),

            const SizedBox(height: 40),
            NeonButton(
              text: 'CREAR CUENTA',
              onTap: () {},
              color: EmpoderateTheme.goldStrong,
              textColor: Colors.black,
            ),

            const SizedBox(height: 24),
            TextButton(
              onPressed: () {},
              child: Text(
                '¿Ya tienes cuenta? Iniciar Sesión',
                style: EmpoderateTheme.subtitleStyle.copyWith(color: EmpoderateTheme.cyanAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: EmpoderateTheme.subtitleStyle.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: EmpoderateTheme.glass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
