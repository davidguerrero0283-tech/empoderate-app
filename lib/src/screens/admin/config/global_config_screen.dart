import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../../components/neon_widgets.dart';
import '../../../components/premium_scaffold.dart';
import '../../../navigation/app_routes.dart';

class GlobalConfigScreen extends StatefulWidget {
  const GlobalConfigScreen({Key? key}) : super(key: key);

  @override
  State<GlobalConfigScreen> createState() => _GlobalConfigScreenState();
}

class _GlobalConfigScreenState extends State<GlobalConfigScreen> {
  // Config Params
  bool _isDarkTheme = true; // Mock for now
  String _language = 'Es (Español)';
  String _env = 'Production (Beta)';
  String _version = '1.0.2 (Build 45)';

  void _exportConfig() {
    // Demo Export
    final config = {
      "app": "Empodérate App",
      "version": _version,
      "env": _env,
      "theme": _isDarkTheme ? "dark" : "light",
      "lang": "es_PA",
      "timestamp": DateTime.now().toIso8601String()
    };
    
    final jsonStr = const JsonEncoder.withIndent('  ').convert(config);
    
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Exportar Configuración'),
      backgroundColor: const Color(0xFF0F172A),
      content: SingleChildScrollView(
         child: SelectableText(jsonStr, style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ElevatedButton.icon(
           icon: const Icon(Icons.copy), 
           label: const Text('Copiar'), 
           onPressed: () {
             Navigator.pop(ctx);
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado al portapapeles (Simulado)')));
           }
        )
      ],
    ));
  }
  
  void _resetConfig() {
     showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('¿Restablecer Valores?'),
      content: const Text('Esto restaurará la configuración predeterminada de la app. No afectará los datos de usuarios ni la base de datos.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        TextButton(
           child: const Text('Restablecer', style: TextStyle(color: Colors.red)), 
           onPressed: () {
             Navigator.pop(ctx);
             // TODO: Call logic
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuración restablecida')));
           }
        )
      ],
    )); 
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Configuración Global',
      showBackButton: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // A) App Settings (Read Only)
             _buildSectionTitle('INFORMACIÓN DE LA APP'),
             _buildInfoCard(
               child: Column(
                 children: [
                   _buildRow('Nombre del Sistema', 'Empodérate Admin Suite'),
                   const Divider(color: Colors.white10),
                   _buildRow('Versión Actual', _version),
                   const Divider(color: Colors.white10),
                   _buildRow('Entorno', _env, badgeColor: Colors.orangeAccent),
                 ],
               )
             ),
             
             const SizedBox(height: 32),
             
             // B) Preferences
             _buildSectionTitle('PREFERENCIAS'),
             _buildInfoCard(
               child: Column(
                 children: [
                   SwitchListTile(
                     title: const Text('Tema Oscuro', style: TextStyle(color: Colors.white)),
                     subtitle: const Text('Estilo visual neón/nocturno', style: TextStyle(color: Colors.white38, fontSize: 12)),
                     value: _isDarkTheme, 
                     activeColor: Colors.purpleAccent,
                     onChanged: (v) => setState(() => _isDarkTheme = v)
                   ),
                   const Divider(color: Colors.white10),
                   ListTile(
                     title: const Text('Idioma (UI)', style: TextStyle(color: Colors.white)),
                     subtitle: Text(_language, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                     trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white30),
                     onTap: () {}, // Placeholder
                   ),
                 ],
               )
             ),
             
             const SizedBox(height: 32),
             
             // C) System & Flags
             _buildSectionTitle('SISTEMA & CONTROL'),
             _buildNavCard(
               icon: Icons.toggle_on, 
               color: Colors.blueAccent, 
               title: 'Visibilidad de Secciones (Feature Flags)', 
               subtitle: 'Activar/Desactivar módulos en tiempo real',
               onTap: () => context.push(AppRoutes.adminVisibility),
             ),
             const SizedBox(height: 12),
             _buildNavCard(
               icon: Icons.history_edu, 
               color: Colors.amber, 
               title: 'Audit Logs', 
               subtitle: 'Ver registro de actividades',
               onTap: () => context.push(AppRoutes.adminAudit),
             ),
             
             const SizedBox(height: 32),
             
             // D) Tools
             _buildSectionTitle('HERRAMIENTAS AVANZADAS'),
             Row(
               children: [
                 Expanded(
                   child: NeonButton(
                     text: 'Exportar JSON',
                     icon: Icons.download,
                     onTap: _exportConfig,
                     primary: false,
                     color: Colors.teal,
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: NeonButton(
                     text: 'Reset Config',
                     icon: Icons.restore,
                     onTap: _resetConfig,
                     primary: false,
                     color: Colors.redAccent,
                   ),
                 ),
               ],
             )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B), // Dark card
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }
  
  Widget _buildRow(String label, String value, {Color? badgeColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          if (badgeColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: badgeColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              child: Text(value, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12)),
            )
          else
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildNavCard({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
             color: const Color(0xFF151C2B),
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
