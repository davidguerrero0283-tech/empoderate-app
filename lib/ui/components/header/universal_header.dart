// Universal Header - Global Refactor Phase 2
import 'package:flutter/material.dart';
import 'dart:ui' as dart_ui; // For BackdropFilter
import 'package:go_router/go_router.dart';
import '../../../src/navigation/app_routes.dart';
import '../../theme/color_palette.dart';
import '../../theme/empoderate_theme.dart';
import '../../../src/services/user_session.dart';
import '../../../src/services/menu_persistent_state.dart';

PreferredSizeWidget buildUniversalHeader(BuildContext context, {
  required String title,
  String? subtitle,
  bool showBackButton = true,
  bool showProfileButton = true,
  bool showBranding = false,
  bool isNeonTitle = false,
  List<Widget>? actions, 
  VoidCallback? onOpenDrawer,
}) {
  final session = UserSession();
  final bool isLoggedIn = session.isLoggedIn;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  // CONSTANT HEIGHT for consistency
  final double kHeaderHeight = 80.0; // Increased from 76

  return PreferredSize(
    preferredSize: Size.fromHeight(kHeaderHeight + 1), // +1 for separator line
    child: Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: kHeaderHeight,
          backgroundColor: isDark 
              ? const Color(0xFF0F1525)
              : const Color(0xFFF5F3EE),
          flexibleSpace: Container(
            color: isDark ? const Color(0xFF0F1525) : const Color(0xFFF5F3EE),
          ),
          elevation: 0,
          centerTitle: true,
          titleSpacing: 0,

          // LEFT: Back or Menu
          leading: Builder(
            builder: (context) {
              if (showBackButton) {
                return IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                  onPressed: () => Navigator.maybePop(context),
                );
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: _HoverIcon(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.menu,
                            color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
                            size: 26,
                          ),
                          // Circular shape next to hamburger
                          Positioned(
                            right: -12,
                            top: 2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? AppColors.premiumGold : AppColors.lightAccent).withOpacity(0.6),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        if (onOpenDrawer != null) {
                          onOpenDrawer();
                        } else {
                          MenuStateService().toggleMenu(); // Standard behavior
                        }
                      },
                    ),
                  ),
                );
              }
            }
          ),

    // CENTER: Title / Branding
    title: showBranding
      ? InkWell(
          onTap: () => context.go(AppRoutes.home),
          child: const _HoverTitle(),
        )
      : Text(
          title,
          style: isNeonTitle 
            ? TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E), // Dark in light
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                shadows: isDark ? [
                  BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 12),
                ] : [],
              )
            : TextStyle(
                color: isDark ? AppColors.textPrimary : const Color(0xFF1A1A2E), // Dark in light
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
        ),

    // RIGHT: Profile/Action
    actions: [
      if (actions != null) ...actions!,
      
      // Plan Icon - Changes based on user's plan
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _HoverIcon(
          icon: _buildPlanIcon(context),
          onTap: () => context.push(AppRoutes.premiumPlans),
        ),
      ),
      
      if (showProfileButton)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _HoverIcon(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: EmpoderateTheme.circle(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.transparent, width: 1),
              ),
              child: Icon(
                isLoggedIn ? Icons.person : Icons.login,
                color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
                size: 20,
              ),
            ),
            onTap: () {
              if (!isLoggedIn) {
                final currentRoute = GoRouterState.of(context).uri.path;
                if (currentRoute != AppRoutes.login && currentRoute != AppRoutes.register) {
                  context.push(AppRoutes.login);
                }
              } else {
                context.push(AppRoutes.profile);
              }
            },
          ),
        ),
    ],
        ),
        // SEPARATOR LINE - Gold in both themes
        Container(
          height: 1,
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.premiumGold.withOpacity(0.6)
                : AppColors.lightAccent,
            boxShadow: isDark ? [
              BoxShadow(
                color: AppColors.premiumGold.withOpacity(0.3),
                blurRadius: 4,
              ),
            ] : [
              BoxShadow(
                color: AppColors.lightAccent.withOpacity(0.3),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Helper function to build plan-specific icon
Widget _buildPlanIcon(BuildContext context) {
  final session = UserSession();
  final userPlan = session.userPlan.toLowerCase();
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  IconData icon;
  Color color;
  
  switch (userPlan) {
    case 'free':
    case 'inicio':
      icon = Icons.star;
      color = isDark ? AppColors.premiumGold : const Color(0xFFF5B200);
      break;
    
    case 'emprendedor':
    case 'crecimiento':
      icon = Icons.trending_up;
      color = isDark ? const Color(0xFF00F5FF) : const Color(0xFF0096C7);
      break;
    
    case 'pro':
      icon = Icons.workspace_premium;
      color = isDark ? const Color(0xFF7B2CBF) : const Color(0xFF3A0CA3);
      break;
    
    case 'empresarial':
      icon = Icons.diamond;
      color = const Color(0xFF00D9FF); // Bright cyan - like a real diamond
      break;
    
    default:
      icon = Icons.star;
      color = isDark ? AppColors.premiumGold : const Color(0xFFF5B200);
  }
  
  return Icon(
    icon,
    color: color,
    size: 22,
  );
}

// Hover Icon Widget for header actions
class _HoverIcon extends StatefulWidget {
  final Widget icon;
  final VoidCallback onTap;

  const _HoverIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<_HoverIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_isHovered ? 1.2 : 1.0),
          decoration: BoxDecoration(
            boxShadow: _isHovered ? [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : null,
          ),
          child: widget.icon,
        ),
      ),
    );
  }
}

// Hover Title Widget for EMPODÉRATE branding
class _HoverTitle extends StatefulWidget {
  const _HoverTitle();

  @override
  State<_HoverTitle> createState() => _HoverTitleState();
}

class _HoverTitleState extends State<_HoverTitle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: TextStyle(
              color: isDark ? AppColors.premiumGold : const Color(0xFF1A1A2E),
              fontSize: _isHovered ? 26 : 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              shadows: [
                if (isDark)
                  BoxShadow(
                    color: AppColors.premiumGold.withOpacity(_isHovered ? 0.5 : 0.3),
                    blurRadius: _isHovered ? 12 : 8,
                  ),
                if (!isDark && _isHovered)
                  BoxShadow(
                    color: const Color(0xFFF5B200).withOpacity(0.4),
                    blurRadius: 10,
                  ),
              ],
            ),
            child: const Text("EMPODÉRATE"),
          ),
          const SizedBox(height: 2),
          Text(
            "Aprende • Implementa • Crece",
            style: TextStyle(
              color: isDark 
                  ? AppColors.textPrimary.withOpacity(0.7)
                  : const Color(0xFF6C6C80),
              fontSize: 10,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
