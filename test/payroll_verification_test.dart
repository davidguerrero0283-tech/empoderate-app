
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_empoderate/src/features/payroll/domain/payroll_engine.dart';
import 'package:proyecto_empoderate/src/features/payroll/domain/payroll_constants.dart';

void main() {
  group('PayrollEngineV2 Comprehensive Tests', () {
    
    // CASE 1: Standard Salary $800
    test('Salario 800.00 -> Full Component Verification', () {
      final input = PayrollInputV2(
        baseSalary: 800.0,
        frequency: PayrollFrequencyV2.mensual,
      );
      final result = PayrollEngineV2.calculate(input);
      
      // GROSS
      expect(result.grossIncome, closeTo(800.00, 0.01));

      // EMPLOYEE DEDUCTIONS
      // SS: 800 * 0.0975 = 78.00
      expect(result.ssEmployee, closeTo(78.00, 0.01));
      // SE: 800 * 0.0125 = 10.00
      expect(result.seEmployee, closeTo(10.00, 0.01));
      // Taxable: 800 - 88 = 712.00
      expect(result.netTaxableIncome, closeTo(712.00, 0.01));
      // ISR: 712 < 846.15 -> 0.00
      expect(result.isr, closeTo(0.00, 0.01));
      
      // NET SALARY
      // 800 - 78 - 10 - 0 = 712.00
      expect(result.netSalary, closeTo(712.00, 0.01));

      // EMPLOYER COSTS
      // SS Patrono: 800 * 0.1225 = 98.00
      expect(result.ssEmployer, closeTo(98.00, 0.01));
      // SE Patrono: 800 * 0.0150 = 12.00
      expect(result.seEmployer, closeTo(12.00, 0.01));
      // Riesgos: 800 * 0.0210 = 16.80
      expect(result.risks, closeTo(16.80, 0.01));
      
      // Total Cost: 800 + 98 + 12 + 16.80 = 926.80
      expect(result.totalEmployerCost, closeTo(926.80, 0.01));
    });

    // CASE 2: Decimal Salary $999.99
    test('Salario 999.99 -> Decimals & Precision', () {
      final input = PayrollInputV2(
        baseSalary: 999.99,
        frequency: PayrollFrequencyV2.mensual,
      );
      final result = PayrollEngineV2.calculate(input);
      
      // SS: 999.99 * 0.0975 = 97.499025 -> ~97.50
      expect(result.ssEmployee, closeTo(97.499025, 0.0001)); 
      // SE: 999.99 * 0.0125 = 12.499875 -> ~12.50
      expect(result.seEmployee, closeTo(12.499875, 0.0001));
      
      // Taxable: 999.99 - (97.499025 + 12.499875) = 999.99 - 109.9989 = 889.9911
      expect(result.netTaxableIncome, closeTo(889.9911, 0.0001));
      
      // ISR: (889.9911 - 846.15) * 0.15 = 43.8411 * 0.15 = 6.576165
      expect(result.isr, closeTo(6.576165, 0.0001));
      
      // Net: 999.99 - 109.9989 - 6.576165 = 883.414935
      expect(result.netSalary, closeTo(883.4149, 0.0001));
    });

    // CASE 3: Salary $0.00
    test('Salario 0.00 -> All Zeros', () {
      final input = PayrollInputV2(baseSalary: 0.0, frequency: PayrollFrequencyV2.mensual);
      final result = PayrollEngineV2.calculate(input);
      expect(result.grossIncome, 0.0);
      expect(result.ssEmployee, 0.0);
      expect(result.isr, 0.0);
      expect(result.netSalary, 0.0);
    });

    // CASE 4: Negative Salary (Should handle gracefully)
    test('Salario -500.00 -> Should not crash (Logic might return negatives)', () {
       final input = PayrollInputV2(baseSalary: -500.0, frequency: PayrollFrequencyV2.mensual);
       final result = PayrollEngineV2.calculate(input);
       // We verify it returns standard calculation (linear) even if negative, without crashing
       expect(result.netSalary, isNotNull);
       expect(result.ssEmployee, closeTo(-48.75, 0.01));
    });

    // --- ISR EDGE CASES (Prompt 100) ---
    test('EDGE: Taxable 846.15 -> ISR 0.00 (Exact Limit)', () {
      final targetTaxable = 846.15;
      final gross = targetTaxable / 0.89; 
      final input = PayrollInputV2(baseSalary: gross, frequency: PayrollFrequencyV2.mensual);
      final result = PayrollEngineV2.calculate(input);
      
      expect(result.netTaxableIncome, closeTo(targetTaxable, 0.0001));
      expect(result.isr, equals(0.0)); 
    });

    test('EDGE: Taxable 846.16 -> ISR > 0 (Just Over Limit)', () {
      final targetTaxable = 846.16;
      final gross = targetTaxable / 0.89; 
      final input = PayrollInputV2(baseSalary: gross, frequency: PayrollFrequencyV2.mensual);
      final result = PayrollEngineV2.calculate(input);
      
      expect(result.netTaxableIncome, closeTo(targetTaxable, 0.0001));
      // Excess = 0.01. Tax = 0.01 * 0.15 = 0.0015
      expect(result.isr, closeTo(0.0015, 0.0001)); 
    });

    test('EDGE: Taxable 3846.15 -> ISR 450.00 (Exact Top of 15%)', () {
      final targetTaxable = 3846.15;
      final gross = targetTaxable / 0.89; 
      final input = PayrollInputV2(baseSalary: gross, frequency: PayrollFrequencyV2.mensual);
      final result = PayrollEngineV2.calculate(input);

      expect(result.netTaxableIncome, closeTo(targetTaxable, 0.0001));
      expect(result.isr, closeTo(450.00, 0.0001));
    });

    test('EDGE: Taxable 3846.16 -> ISR 450.0025 (Just into 25%)', () {
      final targetTaxable = 3846.16;
      final gross = targetTaxable / 0.89; 
      final input = PayrollInputV2(baseSalary: gross, frequency: PayrollFrequencyV2.mensual);
      final result = PayrollEngineV2.calculate(input);

      expect(result.netTaxableIncome, closeTo(targetTaxable, 0.0001));
      expect(result.isr, closeTo(450.0025, 0.0001));
    });

  });
}
