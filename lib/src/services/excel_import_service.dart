// import 'dart:io'; // Removed for Web compatibility
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class ParsedShift {
  final String cedula;
  final String nombre;
  final DateTime date;
  final String entryTime; // HH:mm
  final String exitTime;  // HH:mm
  final bool isValid;
  final String error;

  ParsedShift({
    required this.cedula,
    required this.nombre,
    required this.date,
    required this.entryTime,
    required this.exitTime,
    this.isValid = true,
    this.error = '',
  });
}

class ExcelImportService {
  
  /// Generates a template Excel file bytes
  List<int>? generateTemplate() {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Plantilla_Horas'];
    
    // Header
    List<String> headers = ['Cedula', 'Nombre', 'Fecha (DD/MM/YYYY)', 'Hora Entrada (HH:mm)', 'Hora Salida (HH:mm)'];
    
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
    
    // Add example row
    sheet.appendRow([
      TextCellValue('8-123-456'), 
      TextCellValue('Juan Perez'), 
      TextCellValue('15/01/2026'), 
      TextCellValue('08:00'), 
      TextCellValue('17:00')
    ]);
    
    // Remove default sheet
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }
    
    return excel.encode();
  }

  Future<List<ParsedShift>> parseFile(PlatformFile file) async {
    List<ParsedShift> results = [];
    
    try {
      var bytes = file.bytes;
      if (bytes == null) {
         throw Exception('No data to read (Bytes are null). Ensure withData: true is used.');
      }

      var excel = Excel.decodeBytes(bytes);
      // Assume first sheet
      if (excel.tables.isEmpty) throw Exception('Excel empty');
      
      var table = excel.tables[excel.tables.keys.first];
      
      if (table == null || table.maxRows < 2) return []; // Empty or only header

      // Skip header (row 0)
      for (var i = 1; i < table.maxRows; i++) {
        var row = table.rows[i];
        if (row.isEmpty) continue;
        
        try {
          // Columns: 0=Cedula, 1=Nombre, 2=Fecha, 3=In, 4=Out
          var cedula = _getCellValue(row[0]);
          var nombre = _getCellValue(row[1]);
          var fechaStr = _getCellValue(row[2]);
          var inTime = _getCellValue(row[3]);
          var outTime = _getCellValue(row[4]);

          if (cedula.isEmpty && nombre.isEmpty) continue; // Skip empty rows

          // Parse Date
          DateTime? date;
          try {
             // Handle Excel date double or String
             // Simple string parse for DD/MM/YYYY
             if (fechaStr.contains('/')) {
                date = DateFormat('dd/MM/yyyy').parse(fechaStr);
             } else if (fechaStr.contains('-')) {
                date = DateFormat('yyyy-MM-dd').parse(fechaStr);
             }
          } catch (e) {
             // Invalid date
          }

          bool valid = true;
          String err = '';
          
          if (date == null) {
            valid = false;
            err += 'Fecha inválida. ';
          }
          if (inTime.isEmpty || outTime.isEmpty) {
            valid = false;
            err += 'Horas requeridas. ';
          }

          results.add(ParsedShift(
            cedula: cedula,
            nombre: nombre,
            date: date ?? DateTime.now(),
            entryTime: inTime,
            exitTime: outTime,
            isValid: valid,
            error: err,
          ));

        } catch (e) {
           results.add(ParsedShift(
             cedula: 'Error', 
             nombre: '', 
             date: DateTime.now(), 
             entryTime: '', 
             exitTime: '', 
             isValid: false, 
             error: 'Fila corrupta: $e'
           ));
        }
      }
    } catch (e) {
      print('Excel Error: $e');
      throw e;
    }
    
    return results;
  }

  String _getCellValue(Data? cell) {
    if (cell == null) return '';
    return cell.value.toString();
  }
}
