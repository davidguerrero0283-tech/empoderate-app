import 'salario_models.dart';
import 'pa_recargo_rules.dart';
import '../features/payroll/domain/payroll_engine.dart';

class SalarioLogic {
  static SalarioResultModel calculate(SalarioInputModel input) {
    // --- STEP 1: BASE DATA ---
    double hourlyRate = input.hourlyRate; 
    double periodBaseSalary;
    PayrollFrequencyV2 freqV2;

    if (input.frequency == PayrollFrequency.quincenal) {
      periodBaseSalary = input.baseSalary / 2;
      freqV2 = PayrollFrequencyV2.quincenal;
    } else if (input.frequency == PayrollFrequency.semanal) {
      periodBaseSalary = input.baseSalary / 4.3333;
      freqV2 = PayrollFrequencyV2.semanal;
    } else {
      periodBaseSalary = input.baseSalary;
      freqV2 = PayrollFrequencyV2.mensual;
    }

    // --- STEP 2: ORDINARY HOURS CALCULATION (Art 30-31Equivalencies) ---
    // Calculate total effective ordinary hours for this calculation event
    // Note: This is usually for extra hours calculation reference or specific days worked.
    // If the user inputs Ordinary hours, we pay them ON TOP of base? 
    // Usually Base Salary covers normal hours. 
    // INTERPRETATION: The user wants to calculate specific days (e.g. Sunday work).
    // If input.horasDiurnasOrd > 0, it means we are calculating payment for these specific hours
    // potentially as "worked on rest day" or similar, OR just checking value.
    // BUT typically Base Salary includes normal M-F work.
    // WE WILL ASSUME: Inputs are for ADDITIONAL calculations or Specific shifts entered.
    // However, if "Domingo" is selected, the Base Salary does NOT cover it (it's extra 1.5x) unless shift work.
    // Let's implement: Calculated Value = Hours * Rate * Factors.
    
    // Equivalent Hours (Art. 30, 31)
    double equivDiurna = input.horasDiurnasOrd; // 1:1
    double equivMixta = input.horasMixtasOrd * PaRecargoRules.FACTOR_EQUIV_MIXTO; // 7.5 -> 8
    double equivNocturna = input.horasNocturnasOrd * PaRecargoRules.FACTOR_EQUIV_NOCTURNO; // 7 -> 8
    
    double totalEquivOrdHours = equivDiurna + equivMixta + equivNocturna;
    
    // Value of Ordinary Hours (Art. 48, 49 - Day Factor)
    double factorDia = PaRecargoRules.getFactorDia(input.diaTipo);
    double pagoOrdinario = totalEquivOrdHours * hourlyRate * factorDia;

    // --- STEP 3: EXTRA HOURS CALCULATION (Art. 33 + Art. 50) ---
    // 25% Extra Diurna
    double valExtraDiurna = input.horasExtraDiurna * PaRecargoRules.calcTarifaExtra(
      baseRate: hourlyRate, 
      diaTipo: input.diaTipo, 
      recargoExtra: PaRecargoRules.RECARGO_EXTRA_DIURNA // 0.25
    );
    
    // 50% Extra Nocturna
    double valExtraNocturna = input.horasExtraNocturna * PaRecargoRules.calcTarifaExtra(
      baseRate: hourlyRate, 
      diaTipo: input.diaTipo, 
      recargoExtra: PaRecargoRules.RECARGO_EXTRA_NOCTURNA // 0.50
    );
    
    // 75% Extra Mixta/Nocturna Extension
    double valExtraMixtaNoct = input.horasExtraMixtaNocturna * PaRecargoRules.calcTarifaExtra(
      baseRate: hourlyRate, 
      diaTipo: input.diaTipo, 
      recargoExtra: PaRecargoRules.RECARGO_EXTRA_MIXTA_NOCT // 0.75
    );

    double pagoExtras = valExtraDiurna + valExtraNocturna + valExtraMixtaNoct;

    // Total Variable Pay (Overtime + Specific Ordinary Days worked outside base + Direct Inputs)
    // We add the direct amount inputs (Sunday/Holiday/Night $) to the total variable pay
    double directVariablePay = input.sundayAmount + input.holidayAmount + input.nightSurchargeAmount;
    
    double totalVariablePay = pagoOrdinario + pagoExtras + 
                              input.commissions + input.bonuses + input.otherIncome +
                              directVariablePay;

    // --- STEP 4: ENGINE V2 CALL ---
    final engineInput = PayrollInputV2(
      baseSalary: periodBaseSalary,
      frequency: freqV2,
      overtimeAmount: pagoOrdinario + pagoExtras + directVariablePay + input.vacationAmount, // Include vacation pay as gross income
      commissions: input.commissions,
      bonuses: input.bonuses,
      otherIncome: input.otherIncome,
      otherDeductions: input.otherDeductions,
      isDecimoTercerMes: input.tipoPago == TipoPago.decimoTercerMes,
    );

    final resultV2 = PayrollEngineV2.calculate(engineInput);

    // --- STEP 5: SNAPSHOT FACTORS ---
    Map<String, dynamic> factors = {
      'diaTipo': input.diaTipo.toString().split('.').last,
      'factorDia': factorDia,
      'tasaHora': hourlyRate,
    };

    // --- STEP 6: RETURN RESULT ---
    return SalarioResultModel(
      baseIncome: periodBaseSalary,
      pagoOrdinario: pagoOrdinario,
      pagoExtras: pagoExtras,
      factoresAplicados: factors,
      
      // Legacy mapping (Extras breakdown)
      overtimeDaytimeAmount: valExtraDiurna,
      overtimeNightAmount: valExtraNocturna,
      overtimeMixedAmount: valExtraMixtaNoct,
      
      commissionsAmount: input.commissions,
      bonusesAmount: input.bonuses,
      otherIncomeAmount: input.otherIncome,
      totalDevengado: resultV2.grossIncome,
      
      css: resultV2.ssEmployee,
      se: resultV2.seEmployee,
      isr: resultV2.isr,
      otherDeductions: resultV2.otherDeductions,
      totalDeducciones: resultV2.totalDeductions,
      netSalary: resultV2.netSalary,
      rentaNetaGravable: resultV2.netTaxableIncome,
      
      ssPatrono: resultV2.ssEmployer,
      sePatrono: resultV2.seEmployer,
      riesgos: resultV2.risks,
      costoTotalEmpresa: resultV2.totalEmployerCost,
      
      decimoTercerMes: resultV2.xiii,
      vacaciones: resultV2.vacations,
      primaAntiguedad: resultV2.seniorityPremium,
      totalPrestaciones: resultV2.totalProvisions,
      vacationPayment: input.vacationAmount, // Pass through the actual payment
      
      // Pass through custom deductions
      customDeductions: input.customDeductions,

      // Direct Inputs passed back
      sundayAmount: input.sundayAmount, 
      holidayAmount: input.holidayAmount,
      nightSurchargeAmount: input.nightSurchargeAmount,
    );
  }
}

