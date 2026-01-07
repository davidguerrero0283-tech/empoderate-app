import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../navigation/app_routes.dart';
import '../services/user_session.dart';

class AuthScreen extends StatefulWidget {
  final bool isLoginMode;
  const AuthScreen({Key? key, this.isLoginMode = true}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLoginMode;
  }

  void _submit() {
    UserSession().login(
        _nameController.text.isEmpty ? 'David Guerrero' : _nameController.text,
        _emailController.text,
        plan: 'Free');
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.root, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: _isLogin ? 'INICIAR SESIÓN' : 'REGISTRO',
      showBackButton: true,
      showProfileActions: false, // Ensure no profile/register icon appears
      useScroll: false, // Manual scroll for centering
      usePadding: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: NeonCard(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isLogin ? Icons.lock_open : Icons.person_add,
                    color: kNeonGold,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin ? 'Bienvenido de nuevo' : 'Crea tu cuenta',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin 
                      ? 'Ingresa tus credenciales para continuar.' 
                      : 'Únete a la comunidad de emprendedores.',
                    style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  if (!_isLogin) ...[
                    _buildInput('Nombre Completo', _nameController, Icons.person_outline),
                    const SizedBox(height: 16),
                  ],
                  _buildInput('Correo Electrónico', _emailController, Icons.email_outlined),
                  const SizedBox(height: 16),
                  _buildInput('Contraseña', _passwordController, Icons.lock_outline, obscure: true),
                  
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    _buildInput('Confirmar Contraseña', TextEditingController(), Icons.lock_outline, obscure: true),
                  ],

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: NeonButton(
                      text: _isLogin ? 'INGRESAR' : 'CREAR CUENTA',
                      onTap: _submit,
                      color: kNeonGold,
                      textColor: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.outfit(color: Colors.white70),
                        children: [
                          TextSpan(text: _isLogin ? '¿Aún no tienes cuenta? ' : '¿Ya tienes cuenta? '),
                          TextSpan(
                            text: _isLogin ? 'Regístrate' : 'Inicia Sesión',
                            style: TextStyle(color: kNeonCyan, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        NeonInput( 
          label: label,
          controller: controller,
          obscureText: obscure,
          // icon: icon, // Not supported directly or use suffixIcon if needed? No prefix icon support in NeonInput currently.
        ),
      ],
    );
  }
}
