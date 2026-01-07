import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/components/neon_widgets.dart';
import 'package:proyecto_empoderate/src/features/accounting/classroom/classroom_guides_tab.dart';
import 'package:proyecto_empoderate/src/features/accounting/classroom/classroom_tables_tab.dart';
import 'package:proyecto_empoderate/src/features/accounting/classroom/classroom_lab_tab.dart';
import 'package:proyecto_empoderate/src/features/accounting/classroom/classroom_quiz_tab.dart';

class AccountingClassroomScreen extends StatelessWidget {
  const AccountingClassroomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Reduced from 5: Removed "Herramientas Pro"
      child: PremiumScaffold(
        title: 'Aula: Control y decisiones',
        isNeonTitle: true,
        showBackButton: true,
        useScroll: false,
        body: Column(
          children: [
            // Header Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Aprende y practica con ejemplos reales.',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                isScrollable: true,
                indicatorColor: kNeonGold,
                labelColor: kNeonGold,
                unselectedLabelColor: Colors.white54,
                labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Guías'),
                  Tab(text: 'Tablas y Ejemplos'),
                  Tab(text: 'Laboratorio'),
                  Tab(text: 'Quiz (Prueba)'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Views
            Expanded(
              child: TabBarView(
                children: [
                  const ClassroomGuidesTab(),
                  const ClassroomTablesTab(),
                  const ClassroomLabTab(),
                  const ClassroomQuizTab(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
