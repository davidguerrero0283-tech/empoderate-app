import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../ui/theme/empoderate_theme.dart';
import '../../../screens/admin/admin_dashboard_screen.dart';
import '../../../navigation/app_routes.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AdminLayout({Key? key, required this.child, required this.currentRoute}) : super(key: key);

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _isSidebarCollapsed = false;

  static bool safeMode = false;
  
  @override
  void initState() {
    super.initState();
    print("ADMIN V2 INITIALIZED - SafeMode: $safeMode");
  }

  @override
  Widget build(BuildContext context) {
    if (safeMode) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              const Text("ADMIN SAFE MODE", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("El panel se ha cargado en modo seguro para evitar bloqueos.", style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () => setState(() => safeMode = false),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Intentar Carga Normal"),
              )
            ],
          ),
        ),
      );
    }
    
    final stopwatch = Stopwatch()..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("AdminV2 Render Time: ${stopwatch.elapsedMilliseconds}ms");
      stopwatch.stop();
    });

    return Scaffold(

      backgroundColor: const Color(0xFF0B1120), // Deep admin background
      body: Column(
        children: [
          // FORCE V2 BANNER
          Container(
            width: double.infinity,
            color: Colors.greenAccent.shade700,
            padding: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.center,
            child: Text(
              '✅ ADMIN V2 ACTIVO',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // SIDEBAR

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarCollapsed ? 80 : 260,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Column(
              children: [
                // Header (Logo)
                _buildSidebarHeader(),
                const Divider(color: Colors.white10),
                // Navigation
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildNavItem('Dashboard', Icons.dashboard_outlined, AppRoutes.adminDashboard),
                      _buildNavItem('Analytics', Icons.bar_chart_outlined, AppRoutes.adminAnalytics),
                      
                      _buildSectionHeader('GESTIÓN'),
                      _buildNavItem('Usuarios', Icons.people_outline, AppRoutes.adminUsers),
                      _buildNavItem('Contenido', Icons.article_outlined, AppRoutes.adminContent),
                      
                      _buildSectionHeader('SISTEMA'),
                      _buildNavItem('Visibilidad (Flags)', Icons.toggle_on_outlined, AppRoutes.adminVisibility),
                      _buildNavItem('Auditoría', Icons.history_edu_outlined, AppRoutes.adminAudit),
                      _buildNavItem('Salud', Icons.monitor_heart_outlined, AppRoutes.adminSystem),
                      
                      _buildSectionHeader('INTELIGENCIA'),
                      _buildNavItem('Admin Copilot', Icons.auto_awesome, AppRoutes.adminAi),
                    ],
                  ),
                ),
                // Footer
                _buildSidebarFooter(),
              ],
            ),
          ),

          // MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                // TOPBAR
                _buildTopbar(),
                
                // PAGE CONTENT
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildSidebarHeader() {
    return Container(
      height: 70,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: _isSidebarCollapsed ? 0 : 24),
      child: _isSidebarCollapsed 
        ? Center(child: Icon(Icons.shield, color: EmpoderateTheme.goldStrong, size: 32))
        : Row(
            children: [
              Icon(Icons.shield, color: EmpoderateTheme.goldStrong, size: 28),
              const SizedBox(width: 12),
              Text(
                'ADMIN PRO',
                style: GoogleFonts.outfit(
                  color: Colors.white, 
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    if (_isSidebarCollapsed) return const SizedBox(height: 16);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNavItem(String title, IconData icon, String route) {
    bool isActive = widget.currentRoute == route;
    // Just simple exact match for now, ideally startsWith

    return Tooltip(
      message: _isSidebarCollapsed ? title : '',
      child: InkWell(
        onTap: () {
          if (!isActive) {
            // Use go_router for navigation
            context.go(route);
          }
        },
        child: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? EmpoderateTheme.goldStrong.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? EmpoderateTheme.goldStrong.withOpacity(0.5) : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              SizedBox(width: _isSidebarCollapsed ? 0 : 16),
              Icon(
                icon, 
                color: isActive ? EmpoderateTheme.goldStrong : Colors.white54, 
                size: 22
              ),
              if (!_isSidebarCollapsed) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: isActive ? EmpoderateTheme.goldStrong : Colors.white70,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _isSidebarCollapsed ? Icons.keyboard_double_arrow_right : Icons.keyboard_double_arrow_left,
            color: Colors.white54,
            size: 20
          ),
        ),
      ),
    );
  }

  Widget _buildTopbar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
           // Breadcrumb or Title
           Column(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text('Empodérate App', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
               Text('Dashboard Ejecutivo', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
             ],
           ),
           const Spacer(),

           // Create button to go back to App
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.exit_to_app, size: 18),
              label: const Text('Volver al App'),
              style: TextButton.styleFrom(foregroundColor: Colors.white54),
            ),
           const SizedBox(width: 16),
           
           // Search
           Container(
             width: 200,
             height: 40,
             padding: const EdgeInsets.symmetric(horizontal: 12),
             decoration: BoxDecoration(
               color: Colors.white.withOpacity(0.05),
               borderRadius: BorderRadius.circular(20),
             ),
             child: Row(
               children: [
                 const Icon(Icons.search, color: Colors.white38, size: 18),
                 const SizedBox(width: 8),
                 Text('Buscar...', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13)),
               ],
             ),
           ),
           const SizedBox(width: 16),
           
           // Avatar
           const CircleAvatar(
             radius: 18,
             backgroundColor: Color(0xFF1E293B),
             child: Icon(Icons.person, color: Colors.white, size: 20),
           ),
        ],
      ),
    );
  }
}
