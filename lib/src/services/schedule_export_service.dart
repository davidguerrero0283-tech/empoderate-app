import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../calculators/schedule_models.dart';
import '../calculators/salario_models.dart';

class ScheduleExportService {
  
  /// Generates a PDF document for the given schedule and returns the bytes.
  Future<Uint8List> generateSchedulePdf(WeeklySchedule schedule, List<WorkerProfile> workers, ScheduleTemplate template) async {
    final pdf = pw.Document();
    
    // Load custom font if possible, otherwise use standard
    final font = await PdfGoogleFonts.outfitRegular();
    final boldFont = await PdfGoogleFonts.outfitBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Horario Semanal: ${template.name}', style: pw.TextStyle(font: boldFont, fontSize: 18)),
                    pw.Text(
                      '${DateFormat('dd/MM/yyyy').format(schedule.startDate)} - ${DateFormat('dd/MM/yyyy').format(schedule.endDate)}',
                      style: pw.TextStyle(font: font, fontSize: 14),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              _buildPdfGrid(schedule, workers, template, font, boldFont),
              pw.SizedBox(height: 20),
              pw.Text(
                'Generado por Empodérate App - RRHH',
                style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfGrid(WeeklySchedule schedule, List<WorkerProfile> workers, ScheduleTemplate template, pw.Font font, pw.Font boldFont) {
    const tableHeaders = ['Empleado', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: tableHeaders.map((h) => pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Center(child: pw.Text(h, style: pw.TextStyle(font: boldFont, fontSize: 10))),
          )).toList(),
        ),
        
        // Data Rows
        ...workers.map((worker) {
          return pw.TableRow(
            children: [
              // Employee Name
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(worker.name, style: pw.TextStyle(font: boldFont, fontSize: 10)),
              ),
              // Days
              ...List.generate(7, (i) {
                final dayNum = i + 1;
                final assignment = schedule.assignments.firstWhere(
                  (a) => a.workerId == worker.id && a.date.weekday == dayNum,
                  orElse: () => WorkerAssignment(workerId: worker.id, workerName: worker.name, date: DateTime.now()),
                );
                
                String text = '';
                PdfColor bgColor = PdfColors.white;
                PdfColor textColor = PdfColors.black;

                if (assignment.isVacation) {
                  text = 'VACACIONES';
                  bgColor = PdfColors.pink50;
                  textColor = PdfColors.red;
                } else if (assignment.slotId != null) {
                  try {
                    text = template.availableSlots.firstWhere((s) => s.id == assignment.slotId).name;
                    bgColor = PdfColors.blue50;
                  } catch (e) {
                    text = 'Turno';
                  }
                } else {
                  text = 'LIBRE';
                  textColor = PdfColors.grey500;
                }

                return pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  color: bgColor,
                  child: pw.Center(
                    child: pw.Text(
                      text, 
                      style: pw.TextStyle(font: font, fontSize: 8, color: textColor),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  /// Generates a CSV string for the given schedule.
  /// Enhanced version with time ranges, lunch times, and status
  Future<String> generateScheduleCsv(WeeklySchedule schedule, List<WorkerProfile> workers, ScheduleTemplate template) async {
    final buffer = StringBuffer();
    
    // Header with expanded columns
    buffer.writeln('Empleado,Lunes,Almuerzo Lun,Martes,Almuerzo Mar,Miercoles,Almuerzo Mie,Jueves,Almuerzo Jue,Viernes,Almuerzo Vie,Sabado,Almuerzo Sab,Domingo,Almuerzo Dom,Horas Totales,Dias Trabajados');
    
    for (var worker in workers) {
      final List<String> row = [worker.name];
      int totalMinutes = 0;
      int daysWorked = 0;

      for (int i = 1; i <= 7; i++) {
        final assignment = schedule.assignments.firstWhere(
          (a) => a.workerId == worker.id && a.date.weekday == i,
          orElse: () => WorkerAssignment(workerId: worker.id, workerName: worker.name, date: DateTime.now()),
        );

        String shiftText = '';
        String lunchText = '';

        if (assignment.isVacation) {
          shiftText = 'VACACIONES';
          lunchText = '-';
        } else if (assignment.slotId != null) {
          try {
            final slot = template.availableSlots.firstWhere((s) => s.id == assignment.slotId);
            // Format time range
            shiftText = '${_formatTimeShort(slot.startTime)} - ${_formatTimeShort(slot.endTime)}';
            
            // Calculate and add lunch time (estimated based on position)
            final lunchHour = 11 + (workers.indexOf(worker) % 5); // Rotate 11, 12, 13, 14, 15
            lunchText = '$lunchHour:30';
            
            // Calculate duration
            int start = slot.startTime.hour * 60 + slot.startTime.minute;
            int end = slot.endTime.hour * 60 + slot.endTime.minute;
            if (end <= start) end += 24 * 60;
            totalMinutes += (end - start);
            daysWorked++;
          } catch (e) {
            shiftText = 'Turno';
            lunchText = '-';
          }
        } else {
          shiftText = 'LIBRE';
          lunchText = '-';
        }
        
        row.add(shiftText);
        row.add(lunchText);
      }
      
      // Total hours and days
      row.add('${(totalMinutes / 60).toStringAsFixed(1)}h');
      row.add(daysWorked.toString());
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  String _formatTimeShort(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')}$period';
  }
}
