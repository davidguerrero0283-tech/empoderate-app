import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_empoderate/src/calculators/schedule_models.dart';
import 'package:proyecto_empoderate/src/calculators/salario_models.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';

/// Professional Excel export service for schedules
/// Creates formatted .xlsx files with headers, colors, and styling
class ExcelScheduleExportService {

  /// Generate a professional Excel file for the schedule
  Uint8List generateScheduleExcel(ScheduleController controller) {
    final excel = Excel.createExcel();
    final sheet = excel['Horario'];
    excel.delete('Sheet1'); // Remove default sheet

    // Styles
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 12,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#1E1E2C'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final dayStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#6B5B95'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final morningStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#87CEEB'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final afternoonStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#FFA500'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final nightStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#483D8B'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
    );
    final dayOffStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#808080'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
    );
    final holidayStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#FF69B4'),
      fontColorHex: ExcelColor.white,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Row 0: Title
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('P1'));
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('Horario Semanal - ${DateFormat('d MMM yyyy').format(controller.weekStart)}');
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.fromHexString('#1E1E2C'),
      fontColorHex: ExcelColor.fromHexString('#00CED1'),
      horizontalAlign: HorizontalAlign.Center,
    );

    // Row 1: Headers
    final headers = ['Empleado'];
    for (int d = 0; d < controller.totalDays; d++) {
      final date = controller.weekStart.add(Duration(days: d));
      final dayName = DateFormat('EEE', 'es').format(date);
      final holiday = controller.getHolidayForDay(d);
      if (holiday != null) {
        headers.add('🎉 $dayName ${date.day}');
        headers.add('Almuerzo');
      } else {
        headers.add('$dayName ${date.day}');
        headers.add('Almuerzo');
      }
    }
    headers.add('Horas');
    headers.add('Días');

    for (int c = 0; c < headers.length; c++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 1));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = headers[c].contains('Almuerzo') ? dayStyle : headerStyle;
    }

    // Data rows
    int rowIndex = 2;
    for (var worker in controller.workers) {
      int col = 0;
      
      // Employee name
      final nameCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: rowIndex));
      nameCell.value = TextCellValue(worker.name);
      nameCell.cellStyle = CellStyle(bold: true);

      int totalMinutes = 0;
      int daysWorked = 0;

      for (int d = 0; d < controller.totalDays; d++) {
        final shiftId = controller.assignments[worker.id]?[d];
        final shift = controller.getShiftById(shiftId ?? '');
        final cellStatus = controller.getCellStatus(worker.id, d);
        final holiday = controller.getHolidayForDay(d);
        final lunchTime = controller.getLunchTime(worker.id, d);

        String shiftText = '';
        String lunchText = '-';
        CellStyle style = CellStyle(horizontalAlign: HorizontalAlign.Center);

        if (holiday != null && shiftId == null) {
          shiftText = '🎉 FERIADO';
          style = holidayStyle;
        } else if (cellStatus != null && cellStatus.type == CellStatusType.dayOff) {
          shiftText = 'LIBRE';
          style = dayOffStyle;
        } else if (cellStatus != null && cellStatus.type == CellStatusType.sickLeave) {
          shiftText = 'INCAPACIDAD';
          style = CellStyle(
            backgroundColorHex: ExcelColor.fromHexString('#FF4444'),
            fontColorHex: ExcelColor.white,
            horizontalAlign: HorizontalAlign.Center,
          );
        } else if (cellStatus != null && cellStatus.type == CellStatusType.permission) {
          shiftText = 'PERMISO';
          style = CellStyle(
            backgroundColorHex: ExcelColor.fromHexString('#FFA500'),
            fontColorHex: ExcelColor.black,
            horizontalAlign: HorizontalAlign.Center,
          );
        } else if (shift != null) {
          // Format time range
          shiftText = '${_formatTime(shift.startTime)} - ${_formatTime(shift.endTime)}';
          
          // Determine shift type for styling
          final shiftType = controller.getShiftTypeName(shift.id);
          if (shiftType == 'Matutino') {
            style = morningStyle;
          } else if (shiftType == 'Vespertino') {
            style = afternoonStyle;
          } else {
            style = nightStyle;
          }
          
          // Lunch time
          if (lunchTime != null) {
            lunchText = controller.formatLunchTime(lunchTime);
          }

          // Calculate hours
          int start = shift.startTime.hour * 60 + shift.startTime.minute;
          int end = shift.endTime.hour * 60 + shift.endTime.minute;
          if (end <= start) end += 24 * 60;
          totalMinutes += (end - start);
          daysWorked++;
        } else {
          shiftText = '-';
        }

        // Shift cell
        final shiftCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: rowIndex));
        shiftCell.value = TextCellValue(shiftText);
        shiftCell.cellStyle = style;

        // Lunch cell
        final lunchCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: rowIndex));
        lunchCell.value = TextCellValue(lunchText);
        lunchCell.cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);
      }

      // Total hours
      final hoursCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: rowIndex));
      hoursCell.value = TextCellValue('${(totalMinutes / 60).toStringAsFixed(1)}h');
      hoursCell.cellStyle = CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);

      // Days worked
      final daysCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: rowIndex));
      daysCell.value = TextCellValue('$daysWorked');
      daysCell.cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

      rowIndex++;
    }

    // Footer with legend
    rowIndex += 2;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), 
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex));
    final legendCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
    legendCell.value = TextCellValue('Generado por Empodérate - RRHH');
    legendCell.cellStyle = CellStyle(italic: true, fontColorHex: ExcelColor.fromHexString('#888888'));

    // Set column widths
    sheet.setColumnWidth(0, 25); // Employee name
    for (int c = 1; c < headers.length; c++) {
      sheet.setColumnWidth(c, 15);
    }

    return Uint8List.fromList(excel.encode()!);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')}$period';
  }
}
