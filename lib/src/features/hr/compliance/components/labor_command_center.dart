import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hr_compliance_summary_card.dart';
import '../tabs/compliance_tasks_tab.dart';
import '../tabs/compliance_manager_tab.dart';
import '../../../../components/neon_widgets.dart';

class LaborCommandCenter extends StatefulWidget {
  const LaborCommandCenter({Key? key}) : super(key: key);

  @override
  State<LaborCommandCenter> createState() => _LaborCommandCenterState();
}

class _LaborCommandCenterState extends State<LaborCommandCenter> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<State<HrComplianceSummaryCard>> _summaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _refreshData() {
    // Refresh summary card when data changes in tabs
    // This is a simple proactive way to keep stats slightly more synced
    if (_summaryKey.currentState != null) {
        // We cast to dynamic or specific state to call method 
        // In a real app we might use a Provider/Bloc
        (_summaryKey.currentState as dynamic).reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Stats
          HrComplianceSummaryCard(key: _summaryKey),
          
          // Tabs
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.cyanAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: "Calendario y Tareas"),
                Tab(text: "Gestor de Obligaciones"),
              ],
            ),
          ),
          
          // Tab Content (using AnimatedSwitcher or simple build? 
          // Since we have stateful tabs, keeping them alive in TabBarView is better usually, 
          // but let's assume we want them visible immediately)
          SizedBox(
            height: 600, // Fixed height or expandable? Expandable preferred but TabBarView needs constraints.
            // Using a simple tailored view or just switch on index if we rebuilt.
            // But TabBarView is standard.
            child: TabBarView(
              controller: _tabController,
              children: [
                ComplianceTasksTab(onDataChanged: _refreshData),
                ComplianceManagerTab(onDataChanged: _refreshData),
              ],
            ),
          )
        ],
      ),
    );
  }
}
