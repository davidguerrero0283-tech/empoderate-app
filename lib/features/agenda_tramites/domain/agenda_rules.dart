// Business Rules for Agenda de Trámites
// All date calculations and status logic

import 'tramite_event.dart';

class AgendaRules {
  /// Calculate next due date based on start date and periodicity
  static DateTime calcularProximaFecha(
    DateTime fechaInicio,
    Periodicidad periodicidad,
    int? cadaXDias,
  ) {
    final now = DateTime.now();
    
    switch (periodicidad) {
      case Periodicidad.unica:
        return fechaInicio;
        
      case Periodicidad.mensual:
        return _calcularProximaMensual(fechaInicio, now);
        
      case Periodicidad.trimestral:
        return _calcularProximaTrimestral(fechaInicio, now);
        
      case Periodicidad.semestral:
        return _calcularProximaSemestral(fechaInicio, now);
        
      case Periodicidad.anual:
        return _calcularProximaAnual(fechaInicio, now);
        
      case Periodicidad.personalizada:
        if (cadaXDias == null || cadaXDias <= 0) {
          return fechaInicio;
        }
        return _calcularProximaPersonalizada(fechaInicio, now, cadaXDias);
    }
  }

  static DateTime _calcularProximaMensual(DateTime inicio, DateTime now) {
    var proxima = DateTime(now.year, now.month, inicio.day);
    if (proxima.isBefore(now)) {
      proxima = DateTime(now.year, now.month + 1, inicio.day);
    }
    return proxima;
  }

  static DateTime _calcularProximaTrimestral(DateTime inicio, DateTime now) {
    var proxima = inicio;
    while (proxima.isBefore(now)) {
      proxima = DateTime(proxima.year, proxima.month + 3, proxima.day);
    }
    return proxima;
  }

  static DateTime _calcularProximaSemestral(DateTime inicio, DateTime now) {
    var proxima = inicio;
    while (proxima.isBefore(now)) {
      proxima = DateTime(proxima.year, proxima.month + 6, proxima.day);
    }
    return proxima;
  }

  static DateTime _calcularProximaAnual(DateTime inicio, DateTime now) {
    var proxima = DateTime(now.year, inicio.month, inicio.day);
    if (proxima.isBefore(now)) {
      proxima = DateTime(now.year + 1, inicio.month, inicio.day);
    }
    return proxima;
  }

  static DateTime _calcularProximaPersonalizada(DateTime inicio, DateTime now, int dias) {
    var proxima = inicio;
    while (proxima.isBefore(now)) {
      proxima = proxima.add(Duration(days: dias));
    }
    return proxima;
  }

  /// Calculate status based on next due date
  static EstadoTramite calcularEstado(DateTime proximaFecha) {
    final now = DateTime.now();
    final diff = proximaFecha.difference(now).inDays;

    if (diff < 0) {
      return EstadoTramite.vencido;
    } else if (diff <= 7) {
      return EstadoTramite.pendiente;
    } else {
      return EstadoTramite.alDia;
    }
  }

  /// Calculate days remaining until due date
  static int diasRestantes(DateTime proximaFecha) {
    final now = DateTime.now();
    return proximaFecha.difference(now).inDays;
  }

  /// Mark tramite as done - update fechaInicio and recalculate proximaFecha
  static TramiteEvent marcarRealizado(TramiteEvent tramite) {
    final now = DateTime.now();
    final nuevaProximaFecha = calcularProximaFecha(
      now,
      tramite.periodicidad,
      tramite.cadaXDias,
    );
    final nuevoEstado = calcularEstado(nuevaProximaFecha);

    return tramite.copyWith(
      fechaInicio: now,
      proximaFecha: nuevaProximaFecha,
      estado: nuevoEstado,
      updatedAt: now,
    );
  }

  /// Recalculate all fields for a tramite (useful after edit)
  static TramiteEvent recalcular(TramiteEvent tramite) {
    final proximaFecha = calcularProximaFecha(
      tramite.fechaInicio,
      tramite.periodicidad,
      tramite.cadaXDias,
    );
    final estado = calcularEstado(proximaFecha);

    return tramite.copyWith(
      proximaFecha: proximaFecha,
      estado: estado,
      updatedAt: DateTime.now(),
    );
  }
}
