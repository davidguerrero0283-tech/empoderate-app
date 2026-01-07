import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/config/accounting_config.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart'; 
import 'package:proyecto_empoderate/src/features/analytics/analytics_service.dart';

@Deprecated('Use AccountingV2Screen instead')
class AccountingScreenOld extends StatefulWidget {
  const AccountingScreenOld({Key? key}) : super(key: key);

  @override
  State<AccountingScreenOld> createState() => _AccountingScreenOldState();
}

class _AccountingScreenOldState extends State<AccountingScreenOld> {
  // Filter tools
  final List<AccountingToolConfig> _mainTools = accountingTools
      .where((tool) => tool.category == AccountingCategory.main)
      .toList();
      
  final List<AccountingToolConfig> _extraTools = accountingTools
      .where((tool) => tool.category == AccountingCategory.extra)
      .toList();

  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreenView('Accounting Dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return const PremiumScaffold(
      title: 'Mantenimiento',
      body: Center(
        child: Text('Esta pantalla ya no está en uso.\nPor favor usa Contabilidad V2.', 
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white)
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context, AccountingToolConfig tool) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, tool.route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1D), // Dark base
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tool.color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: tool.color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tool.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(tool.icon, color: tool.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.title,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tool.description,
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white30),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(BuildContext context, AccountingToolConfig tool) {
    return NeonGridCard(
      title: tool.title,
      subtitle: '', 
      icon: tool.icon,
      neonColor: tool.color,
      onTap: () => Navigator.pushNamed(context, tool.route),
      backgroundColor: Colors.white.withOpacity(0.05), // Match 'Simple' translucent background
    );
  }
}
