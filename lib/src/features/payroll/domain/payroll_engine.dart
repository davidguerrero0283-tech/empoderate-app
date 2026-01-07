import 'payroll_constants.dart';

enum PayrollFrequencyV2 { mensual, quincenal, semanal }

class PayrollInputV2 {
  final double baseSalary; // Mensual o según frecuencia
  final PayrollFrequencyV2 frequency;
  
  // Income components
  final double overtimeAmount; // Calculated value of hours * rate
  final double commissions;
  final double bonuses;
  final double otherIncome;
  
  // User manual inputs
  final double otherDeductions;
  
  // Panama Law - Décimo Tercer Mes flag
  final bool isDecimoTercerMes;

  PayrollInputV2({
    required this.baseSalary,
    required this.frequency,
    this.overtimeAmount = 0.0,
    this.commissions = 0.0,
    this.bonuses = 0.0,
    this.otherIncome = 0.0,
    this.otherDeductions = 0.0,
    this.isDecimoTercerMes = false,
  });
}

class PayrollResultV2 {
  // Income
  final double grossIncome;
  
  // Deductions
  final double ssEmployee;
  final double seEmployee;
  final double isr;
  final double otherDeductions;
  final double totalDeductions;
  
  // Net
  final double netSalary;
  
  // Meta
  final double netTaxableIncome; // Renta Neta Gravable
  
  // Employer
  final double ssEmployer;
  final double seEmployer;
  final double risks;
  final double totalEmployerCost;
  
  // Provisions
  final double xiii;
  final double vacations;
  final double seniorityPremium;
  final double totalProvisions;

  PayrollResultV2({
    required this.grossIncome,
    required this.ssEmployee,
    required this.seEmployee,
    required this.isr,
    required this.otherDeductions,
    required this.totalDeductions,
    required this.netSalary,
    required this.netTaxableIncome,
    required this.ssEmployer,
    required this.seEmployer,
    required this.risks,
    required this.totalEmployerCost,
    required this.xiii,
    required this.vacations,
    required this.seniorityPremium,
    required this.totalProvisions,
  });
}

class PayrollEngineV2 {
  static PayrollResultV2 calculate(PayrollInputV2 input) {
    // A) Devengado Bruto
    final double grossIncome = input.baseSalary + 
                               input.overtimeAmount + 
                               input.commissions + 
                               input.bonuses + 
                               input.otherIncome;

    // B) Seguro Social & Educativo (Empleado)
    // Panama Law: Décimo Tercer Mes has special rates
    final double ssEmployee = input.isDecimoTercerMes
        ? grossIncome * PayrollConstants.TASA_SS_DECIMO    // 7.25% for XIII
        : grossIncome * PayrollConstants.TASA_SS_EMPLEADO; // 9.75% regular
    
    final double seEmployee = input.isDecimoTercerMes
        ? 0.0  // 0% for XIII month (Panama Law)
        : grossIncome * PayrollConstants.TASA_SE_EMPLEADO; // 1.25% regular

    // C) Renta Neta Gravable
    final double netTaxableIncome = grossIncome - (ssEmployee + seEmployee);

    // D) ISR - Annualized Method (Panama Law)
    // Step 1: Calculate annualized income (13 months)
    double annualizedIncome = netTaxableIncome * 13;
    
    // Step 2: Subtract basic deduction of $11,000
    double taxableBase = annualizedIncome - PayrollConstants.ISR_DEDUCCION_BASICA;
    
    // Step 3: Calculate annual ISR with progressive brackets
    double annualISR = 0.0;
    if (taxableBase <= 0) {
      annualISR = 0.0;
    } else if (taxableBase <= 50000) {
      // 15% on first $50,000
      annualISR = taxableBase * PayrollConstants.ISR_TASA_1;
    } else {
      // 15% on first $50,000 + 25% on excess
      annualISR = (50000 * PayrollConstants.ISR_TASA_1) + 
                  ((taxableBase - 50000) * PayrollConstants.ISR_TASA_2);
    }
    
    // Step 4: De-annualize ISR based on payment frequency
    double periodsPerYear = 12.0;
    if (input.frequency == PayrollFrequencyV2.quincenal) {
      periodsPerYear = 24.0;
    } else if (input.frequency == PayrollFrequencyV2.semanal) {
      periodsPerYear = 52.0;
    }
    
    final double periodISR = annualISR / periodsPerYear;

    // E) Salario Neto
    final double totalDeductions = ssEmployee + seEmployee + periodISR + input.otherDeductions;
    final double netSalary = grossIncome - totalDeductions;

    // Costos Patronales (Unchanged - employer pays normal rates even for XIII)
    final double ssEmployer = grossIncome * PayrollConstants.TASA_SS_PATRONO;
    final double seEmployer = grossIncome * PayrollConstants.TASA_SE_PATRONO;
    final double risks = grossIncome * PayrollConstants.TASA_RIESGOS;
    final double totalEmployerCost = grossIncome + ssEmployer + seEmployer + risks;

    // Prestaciones (Provisions - Estimated accrual per period)
    // XIII Mes (1/12 of earnings)
    final double xiii = grossIncome / 12.0;
    // Vacations (1 month every 11 months -> 1/11 of earnings)
    final double vacations = grossIncome / 11.0;
    // Seniority Premium (1.923%)
    final double seniorityPremium = grossIncome * PayrollConstants.TASA_PRIMA_ANTIGUEDAD;
    final double totalProvisions = xiii + vacations + seniorityPremium;

    return PayrollResultV2(
      grossIncome: grossIncome,
      ssEmployee: ssEmployee,
      seEmployee: seEmployee,
      isr: periodISR,
      otherDeductions: input.otherDeductions,
      totalDeductions: totalDeductions,
      netSalary: netSalary,
      netTaxableIncome: netTaxableIncome,
      ssEmployer: ssEmployer,
      seEmployer: seEmployer,
      risks: risks,
      totalEmployerCost: totalEmployerCost,
      xiii: xiii,
      vacations: vacations,
      seniorityPremium: seniorityPremium,
      totalProvisions: totalProvisions,
    );
  }
}
