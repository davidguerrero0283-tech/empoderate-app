import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/config/accounting_config.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';

class AccountingToolsMenuScreen extends StatelessWidget {
  const AccountingToolsMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Contabilidad Rápida',
      isNeonTitle: true,
      showBackButton: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Acceso directo a todas las herramientas contables.',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
            ),
          ),
          
          if (accountingTools.isEmpty)
             Expanded(child: Center(child: Text('Lista vacía', style: GoogleFonts.outfit(color: Colors.white54))))
          else
             Expanded(
               child: GridView.builder(
                 padding: const EdgeInsets.only(bottom: 40),
                 physics: const BouncingScrollPhysics(),
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 2,
                   crossAxisSpacing: 16,
                   mainAxisSpacing: 16,
                   childAspectRatio: 1.1, // Optimized for NeonGridCard
                 ),
                 itemCount: accountingTools.length,
                 itemBuilder: (context, index) {
                   final tool = accountingTools[index];
                   return _buildGridCard(context, tool);
                 },
               ),
             ),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, AccountingToolConfig tool) {
    return NeonGridCard(
      title: tool.title,
      subtitle: 'Cálculo rápido', // Generic subtitle as requested
      icon: tool.icon,
      neonColor: tool.color,
      // Use a consistent dark glass background
      backgroundColor: const Color(0xFF151C2B), 
      onTap: () => Navigator.pushNamed(context, tool.route),
    );
  }
}
