import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../src/navigation/app_routes.dart';
import '../../../src/services/user_session.dart';

class PremiumHeader extends StatelessWidget {
  final bool showBackButton;
  final String? title;
  final VoidCallback? onBack;

  // Unused params kept for compatibility (ignored)
  final dynamic gradientColors;
  final dynamic titleColor;
  final dynamic titleGlowColor;
  final dynamic iconColor;
  final dynamic borderColor;
  final bool showProfileActions;

  const PremiumHeader({
    Key? key,
    this.showBackButton = false,
    this.title,
    this.onBack,
    this.gradientColors,
    this.titleColor,
    this.titleGlowColor,
    this.iconColor,
    this.borderColor,
    this.showProfileActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Get User Session State
    final session = UserSession();
    final bool usuarioLogueado = session.isLoggedIn;
    final String usuarioPlan = session.userPlan.toLowerCase();

    // 2. Premium AppBar
    return AppBar(
      automaticallyImplyLeading: false, // We control leading manually
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      
      // Premium Global Gradient Background
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF001326), // Deep Navy
              Color(0xFF000A12), // Almost Black
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      
      // Leading Action (Back or Menu)
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
              onPressed: onBack ?? () => Navigator.maybePop(context),
            )
          : Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Menú',
              ),
            ),

      // Title Section
      title: Column(
        children: [
          // Main Title - Premium Gold
          Text(
            (title != null && title!.toUpperCase() != 'EMPODÉRATE') 
                ? title!.toUpperCase() 
                : "EMPODÉRATE",
            style: const TextStyle(
              color: Color(0xFFF5D98A), // Premium Gold
              fontSize: 23,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          // Slogan (Only show if default title or force shown)
          // The prompt implies "El título jamás debe caer ni moverse". So we keep it fixed hierarchy.
          if (title == null || title!.toUpperCase() == 'EMPODÉRATE')
            const Text(
              "Aprende, implementa, crece y transforma tu negocio.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),

      // Right Actions: Plans + User/Plan Icon
      actions: [
        // Home Button (Inicio)
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.home, color: Colors.white70, size: 24),
            tooltip: 'Inicio',
            onPressed: () {
              context.go('/'); // Use go_router
            },
          ),
        ),
        
        // Diamond Icon - Plans Access
        // Diamond Icon - Plans Access
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onTap: () {
                context.push(AppRoutes.premiumPlans);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFF5B200)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.diamond,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        
        // User Profile Icon
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 350), // Smooth 350ms
            curve: Curves.easeOutBack, // ScaleIn effect
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onTap: () {
                if (!usuarioLogueado) {
                  context.push(AppRoutes.login);
                } else {
                  context.push(AppRoutes.profile);
                }
              },
              child: _buildUserPlanIcon(usuarioLogueado ? usuarioPlan : 'guest'),
            ),
          ),
        ),
      ],
    );
  }

  // 3. Plan Icon Logic
  Widget _buildUserPlanIcon(String plan) {
    switch (plan) {
      case 'guest': // Not logged in
        return const Icon(Icons.person_outline, color: Colors.white, size: 22);

      case 'free':
        return const Icon(Icons.person_outline, color: Colors.white, size: 22);

      case 'emprendedor':
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF00F5FF), Color(0xFF0096C7)], // Turquoise Premium
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.home, color: Colors.black, size: 20),
        );

      case 'pro':
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF7B2CBF), Color(0xFF3A0CA3)], // Purple Professional
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.business_center, color: Colors.white, size: 20),
        );

      case 'empresarial':
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFF5B200)], // Intense Gold
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFFD700),
                blurRadius: 12,
                spreadRadius: 1,
              )
            ],
          ),
          child: const Icon(Icons.apartment, color: Colors.black, size: 22),
        );

      default:
        return const Icon(Icons.person_outline, color: Colors.white, size: 22);
    }
  }
}
