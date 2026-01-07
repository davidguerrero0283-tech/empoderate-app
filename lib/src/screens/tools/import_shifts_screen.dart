// import 'dart:io'; // Removed for Web
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:path_provider/path_provider.dart'; // Removed for Web
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; // For Data URI download
import 'dart:convert'; // base64
import '../../components/premium_scaffold.dart';
import '../../components/neon_widgets.dart';
import '../../services/excel_import_service.dart';
 
import '../../calculators/salario_models.dart'; 

class ImportShiftsScreen extends StatefulWidget {
  static const routeName = '/tools/import_shifts';
  const ImportShiftsScreen({Key? key}) : super(key: key);

  @override
  State<ImportShiftsScreen> createState() => _ImportShiftsScreenState();
}

class _ImportShiftsScreenState extends State<ImportShiftsScreen> {
  final ExcelImportService _importService = ExcelImportService();
  List<ParsedShift> _parsedData = [];
  bool _isLoading = false;
  String? _statusMessage;

  Future<void> _downloadTemplate() async {
    try {
      final bytes = _importService.generateTemplate();
      if (bytes == null) return;

      // Web Download via Data URI
      final base64Data = base64Encode(bytes);
      final uri = 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$base64Data';
      
      if (await canLaunchUrl(Uri.parse(uri))) {
         await launchUrl(Uri.parse(uri));
         setState(() {
            _statusMessage = 'Descarga iniciada...';
         });
      } else {
         throw Exception('No se pudo iniciar la descarga.');
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // Critical for Web
      );

      if (result != null) {
        final platformFile = result.files.single;
        final data = await _importService.parseFile(platformFile);
        
        setState(() {
          _parsedData = data;
          _statusMessage = 'Leídas ${data.length} filas.';
        });
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processImport() async {
    if (_parsedData.isEmpty) return;
    
    int success = 0;
    // Mock saving - in real app would call ShiftService
    // For now we assume integration or just show success
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 1)); // Sim saving
    
    // Logic to actually save:
    // Convert ParsedShift -> WorkSheet/Shift logic
    // This requires ShiftService logic which might be complex, so for now we just Validate layout.
    
    setState(() => _isLoading = false);
    
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Importación completada. $_parsedData registros procesados (Simulado).'), backgroundColor: Colors.green),
      );
       context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Importar Turnos',
      subtitle: 'Carga masiva desde Excel',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // STATUS
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: Text(_statusMessage!, style: GoogleFonts.outfit(color: Colors.white)),
              ),
              
            // STEP 1
            NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeonSectionTitle(title: 'PASO 1: Descargar Plantilla'),
                  const SizedBox(height: 12),
                  const Text('Usa este archivo para llenar los datos de los turnos.', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  NeonButton(
                    text: 'Descargar Excel',
                    icon: Icons.download,
                    onTap: _downloadTemplate,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // STEP 2
            NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeonSectionTitle(title: 'PASO 2: Subir Archivo'),
                  const SizedBox(height: 12),
                  const Text('Selecciona el archivo Excel completado.', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  NeonButton(
                    text: 'Seleccionar Archivo',
                    icon: Icons.upload_file,
                    onTap: _pickFile,
                    primary: true,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // PREVIEW
            if (_parsedData.isNotEmpty) ...[
               NeonSectionTitle(title: 'Vista Previa (${_parsedData.length} registros)'),
               const SizedBox(height: 12),
               SingleChildScrollView(
                 scrollDirection: Axis.horizontal,
                 child: DataTable(
                   headingRowColor: MaterialStateProperty.all(Colors.black26),
                   columns: const [
                     DataColumn(label: Text('Nombre', style: TextStyle(color: Colors.white))),
                     DataColumn(label: Text('Fecha', style: TextStyle(color: Colors.white))),
                     DataColumn(label: Text('Entrada', style: TextStyle(color: Colors.white))),
                     DataColumn(label: Text('Salida', style: TextStyle(color: Colors.white))),
                     DataColumn(label: Text('Estado', style: TextStyle(color: Colors.white))),
                   ],
                   rows: _parsedData.map((d) {
                     return DataRow(
                       color: MaterialStateProperty.all(d.isValid ? Colors.transparent : Colors.red.withOpacity(0.1)),
                       cells: [
                         DataCell(Text(d.nombre, style: const TextStyle(color: Colors.white))),
                         DataCell(Text('${d.date.day}/${d.date.month}/${d.date.year}', style: const TextStyle(color: Colors.white70))),
                         DataCell(Text(d.entryTime, style: const TextStyle(color: Colors.white70))),
                         DataCell(Text(d.exitTime, style: const TextStyle(color: Colors.white70))),
                         DataCell(d.isValid 
                            ? const Icon(Icons.check_circle, color: Colors.green, size: 18)
                            : Tooltip(message: d.error, child: const Icon(Icons.error, color: Colors.red, size: 18))
                         ),
                       ],
                     );
                   }).toList(),
                 ),
               ),
               const SizedBox(height: 40),
               NeonButton(
                 text: 'Confirmar e Importar',
                 primary: true,
                 icon: Icons.save_alt,
                 color: const Color(0xFF00E5FF),
                 onTap: _processImport,
               ),
               const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }
}
