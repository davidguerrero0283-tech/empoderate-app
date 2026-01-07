class PayrollConstants {
  // Work Shift Divisors (Panama Law)
  static const double DIVISOR_DIURNA = 208.0;    // 8h/day shift
  static const double DIVISOR_MIXTA = 195.0;     // 7.5h/day shift
  static const double DIVISOR_NOCTURNA = 182.0;  // 7h/day shift
  
  // Employee Deductions
  static const double TASA_SS_EMPLEADO = 0.0975;  // 9.75% regular
  static const double TASA_SE_EMPLEADO = 0.0125;  // 1.25% regular
  static const double TASA_SS_DECIMO = 0.0725;    // 7.25% for XIII month
  
  // Employer Costs
  static const double TASA_SS_PATRONO = 0.1225;
  static const double TASA_SE_PATRONO = 0.0150;
  static const double TASA_RIESGOS = 0.0210;
  
  // Provisions
  static const double TASA_PRIMA_ANTIGUEDAD = 0.01923; // ~1.923%
  
  // ISR - Annualized Method (Panama Law)
  static const double ISR_DEDUCCION_BASICA = 11000.0;  // $11,000 annual basic deduction
  static const double ISR_UMBRAL_1 = 846.15;           // Monthly threshold (deprecated, keeping for compatibility)
  static const double ISR_UMBRAL_2 = 3846.15;          // Monthly threshold (deprecated)
  static const double ISR_TASA_1 = 0.15;               // 15% on first bracket
  static const double ISR_TASA_2 = 0.25;               // 25% on second bracket
  static const double ISR_BASE_2 = 450.00;             // Base for second bracket (deprecated)
}
