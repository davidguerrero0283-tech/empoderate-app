import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/neon_widgets.dart';

class EmpoderaDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows; // Keeping String for compatibility

  const EmpoderaDataTable({
    Key? key,
    required this.columns,
    required this.rows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert List<List<String>> to List<List<Widget>> for NeonTable
    final widgetRows = rows.map((row) {
      return row.map((cell) => Text(
        cell,
        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
      )).toList();
    }).toList();

    return NeonTable(
      headers: columns,
      rows: widgetRows,
      accentColor: kNeonGold, // Keep gold accent for this specific table type if preferred, or use context
    );
  }
}
