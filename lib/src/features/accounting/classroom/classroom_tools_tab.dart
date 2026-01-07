import 'package:flutter/material.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/config/accounting_config.dart';

class ClassroomToolsTab extends StatelessWidget {
  const ClassroomToolsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Defined list of IDs for this tab
    final toolIds = ['budget', 'cash_flow', 'break_even', 'margin', 'fixed_costs', 'tax_estimator'];
    
    // Filter from global config
    final tools = accountingTools.where((t) => toolIds.contains(t.id)).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final tool = tools[index];
        return NeonGridCard(
          title: tool.title,
          subtitle: '',
          icon: tool.icon,
          neonColor: tool.color,
          onTap: () => Navigator.pushNamed(context, tool.route),
          backgroundColor: Colors.white.withOpacity(0.05),
        );
      },
    );
  }
}
