
/// Reglas de Recargos - Código de Trabajo de Panamá
/// Referencias: Arts. 30, 31, 32, 33, 48, 49, 50.

enum DiaTipo {
  normal,               // Día regular de trabajo (Factor 1.0)
  domingo_descanso,     // Domingo o día de descanso semanal (Factor 1.5 - Art. 48)
  fiesta_duelo_nacional // Día de Fiesta o Duelo Nacional (Factor 2.5 - Art. 49)
}

class PaRecargoRules {
  
  // --- FACTORES DE RECARGO (Art. 33) ---
  static const double RECARGO_EXTRA_DIURNA = 0.25;    // +25%
  static const double RECARGO_EXTRA_NOCTURNA = 0.50;  // +50%
  static const double RECARGO_EXTRA_MIXTA_NOCT = 0.75;// +75% (Prolongación)

  // --- FACTORES DE DÍA (Art. 48, 49) ---
  static double getFactorDia(DiaTipo tipo) {
    switch (tipo) {
      case DiaTipo.normal: return 1.0;
      case DiaTipo.domingo_descanso: return 1.50;
      case DiaTipo.fiesta_duelo_nacional: return 2.50;
    }
  }

  // --- EQUIVALENCIAS DE JORNADA (Art. 30-31) ---
  // 7 horas nocturnas = 8 horas diurnas
  static const double FACTOR_EQUIV_NOCTURNO = 8.0 / 7.0; 
  // 7.5 horas mixtas = 8 horas diurnas
  static const double FACTOR_EQUIV_MIXTO = 8.0 / 7.5;

  /// Calcula tarifa por hora ORDINARIA aplicando equivalencia y factor de día.
  /// Ejemplo: Hora Ordinaria en Domingo = tarifaBase * 1.5
  static double calcTarifaOrdinaria({
    required double baseRate, 
    required DiaTipo diaTipo
  }) {
    return baseRate * getFactorDia(diaTipo);
  }

  /// Calcula tarifa por hora EXTRA aplicando Art. 50 (Recargos combinados).
  /// Fórmula: TarifasBase * FactorDia * (1 + RecargoExtra)
  /// Ejemplo: Extra Diurna en Domingo = Base * 1.5 * 1.25 = 1.875x
  static double calcTarifaExtra({
    required double baseRate,
    required DiaTipo diaTipo,
    required double recargoExtra, 
  }) {
    // Primero el recargo del día (ej. domingo 1.5), y sobre eso el recargo extra.
    // Interpretación práctica Art 50: "se pagará con el recargo del día... aumentado en el recargo por horas excedentes"
    // Matemáticamente: Base * FactorDia * (1 + Recargo)
    return baseRate * getFactorDia(diaTipo) * (1 + recargoExtra);
  }
}
