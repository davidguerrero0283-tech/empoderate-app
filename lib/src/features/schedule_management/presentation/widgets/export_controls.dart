import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';

class ExportControls extends StatelessWidget {
  const ExportControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Exportar y Compartir', style: GoogleFonts.outfit(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _exportButton('PDF', Icons.picture_as_pdf, Colors.pinkAccent, () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generando PDF...'), duration: Duration(seconds: 1)),
                  );
                  await context.read<ScheduleController>().exportPdf();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ PDF descargado correctamente'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error al exportar PDF: $e'), backgroundColor: Colors.red),
                  );
                }
              }),
              _exportButton('Excel', Icons.table_chart, Colors.greenAccent, () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generando CSV/Excel...'), duration: Duration(seconds: 1)),
                  );
                  await context.read<ScheduleController>().exportExcel();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Excel descargado correctamente'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error al exportar Excel: $e'), backgroundColor: Colors.red),
                  );
                }
              }),
              
              // SAVE BUTTON (Saving Fix)
              _exportButton(
                'Guardar', 
                Icons.save, 
                Colors.blueAccent, 
                () async {
                  final controller = context.read<ScheduleController>();
                  final success = await controller.saveSchedule();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado correctamente')));
                  }
                }
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _exportButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
