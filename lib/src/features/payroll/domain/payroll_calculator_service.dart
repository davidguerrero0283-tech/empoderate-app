import 'payroll_engine.dart';
import '../../../calculators/salario_models.dart';

/// Extension to PayrollEngineV2 that handles both Base and Hourly payment types
class PayrollCalculatorService {
  /// Calculate payroll based on worker's payment type
  static PayrollResultV2 calculateForWorker({
    required WorkerProfile worker,
    required PayrollFrequency frequency,
    double? hoursWorked,          // Required if hourly
    double? diurnalHours,         // Horas diurnas (optional for detailed calc)
    double? mixedHours,           // Horas mixtas
    double? nightHours,           // Horas nocturnas
    double overtimeAmount = 0.0,
    double commissions = 0.0,
    double bonuses = 0.0,
    double otherIncome = 0.0,
    double otherDeductions = 0.0,
    bool isDecimoTercerMes = false,
  }) {
    double calculatedBaseSalary;
    
    // Determine base salary based on payment type
    if (worker.paymentType == PaymentType.hourly) {
      // HOURLY PAYMENT: Calculate from hours worked
      if (worker.hourlyRate == null) {
        throw Exception('Hourly rate not set for hourly worker: ${worker.name}');
      }
      
      if (hoursWorked == null && diurnalHours == null && mixedHours == null && nightHours == null) {
        throw Exception('Hours must be provided for hourly workers');
      }
      
      // Calculate base from hours
      final rate = worker.hourlyRate!;
      double totalBase = 0.0;
      
      // If detailed hours provided, use them with recargos
      if (diurnalHours != null || mixedHours != null || nightHours != null) {
        // Diurnal hours: Normal rate
        totalBase += (diurnalHours ?? 0.0) * rate;
        
        // Mixed hours: +25% recargo (according to Panama law)
        totalBase += (mixedHours ?? 0.0) * rate * 1.25;
        
        // Night hours: +50% recargo (according to Panama law)
        totalBase += (nightHours ?? 0.0) * rate * 1.50;
      } else {
        // Simple calculation: total hours × rate
        totalBase = (hoursWorked ?? 0.0) * rate;
      }
      
      calculatedBaseSalary = totalBase;
    } else {
      // BASE PAYMENT: Use fixed base salary
      calculatedBaseSalary = worker.basePayment;
    }
    
    // Convert PayrollFrequency to PayrollFrequencyV2
    final PayrollFrequencyV2 freqV2;
    switch (frequency) {
      case PayrollFrequency.mensual:
        freqV2 = PayrollFrequencyV2.mensual;
        break;
      case PayrollFrequency.quincenal:
        freqV2 = PayrollFrequencyV2.quincenal;
        break;
      case PayrollFrequency.semanal:
        freqV2 = PayrollFrequencyV2.semanal;
        break;
    }
    
    // Create input for payroll engine
    final input = PayrollInputV2(
      baseSalary: calculatedBaseSalary,
      frequency: freqV2,
      overtimeAmount: overtimeAmount,
      commissions: commissions,
      bonuses: bonuses,
      otherIncome: otherIncome,
      otherDeductions: otherDeductions,
      isDecimoTercerMes: isDecimoTercerMes,
    );
    
    // Calculate using the engine
    return PayrollEngineV2.calculate(input);
  }
  
  /// Helper to get recargo multipliers
  static Map<String, double> getRecargoMultipliers() {
    return {
      'diurna': 1.0,   // Normal hours: rate × 1.0
      'mixta': 1.25,   // Mixed hours: rate × 1.25 (+25%)
      'nocturna': 1.50, // Night hours: rate × 1.50 (+50%)
    };
  }
  
  /// Calculate expected hours for a period based on shift type
  static double getExpectedHoursPerPeriod(PayrollFrequency frequency, JornadaTipo? shiftType) {
    // Standard hours per month by shift type (Panama law)
    final Map<JornadaTipo, double> monthlyHours = {
      JornadaTipo.diurna: 208,  // 8h/day × 26 days
      JornadaTipo.mixta: 182,   // 7h/day × 26 days
      JornadaTipo.nocturna: 156, // 6h/day × 26 days
    };
    
    final baseMonthly = monthlyHours[shiftType ?? JornadaTipo.diurna] ?? 208;
    
    switch (frequency) {
      case PayrollFrequency.mensual:
        return baseMonthly;
      case PayrollFrequency.quincenal:
        return baseMonthly / 2;
      case PayrollFrequency.semanal:
        return baseMonthly / 4;
    }
  }
}
