import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_empoderate/features/hr/vacation/domain/vacation_calculator_service.dart';

void main() {
  late VacationCalculatorService service;

  setUp(() {
    service = VacationCalculatorService();
  });

  group('Vacation Days Accrual', () {
    test('11 meses de servicio ≈ 30 días de vacaciones', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 12, 1); // ~11 meses = 335 días
      
      final days = service.computeVacationDaysAccrued(
        startDate: start,
        endDate: end,
      );
      
      // 335 días / 11 = 30.45 días, clamp a 30
      expect(days, 30.0);
    });
    
    test('110 días de servicio = 10 días vacaciones', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 4, 20); // 110 días
      
      final days = service.computeVacationDaysAccrued(
        startDate: start,
        endDate: end,
      );
      
      // 110 / 11 = 10.0
      expect(days, closeTo(10.0, 0.1));
    });
    
    test('55 días de servicio = 5 días vacaciones', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 2, 25); // 55 días
      
      final days = service.computeVacationDaysAccrued(
        startDate: start,
        endDate: end,
      );
      
      // 56 días reales / 11 = 5.09 (ajustar tolerancia)
      expect(days, closeTo(5.0, 0.1));
    });
    
    test('Clamp máximo a 30 días por periodo', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2025, 1, 1); // 1 año completo = 366 días
      
      final days = service.computeVacationDaysAccrued(
        startDate: start,
        endDate: end,
      );
      
      // 366 / 11 = 33.27, pero clamp a 30
      expect(days, 30.0);
    });
  });

  group('Vacation Payment - Monthly/Biweekly', () {
    test('Mensual sin variables = salario base', () {
      final pay = service.computeVacationPay(
        frequency: PayrollFrequency.monthly,
        lastBaseSalary: 1000.0,
        hasVariableComponentsOrRecentRaise: false,
        last11MonthsOrdinaryEarnings: List.filled(11, 1000.0),
        last11MonthsExtraordinaryEarnings: List.filled(11, 0.0),
        ordinaryWorkdaysServedLast11Months: 242,
        vacationDaysToPay: 30.0,
      );
      
      // 1000.0 * (30/30) = 1000.0
      expect(pay, 1000.0);
    });
    
    test('Mensual con variables: selecciona el mayor (promedio)', () {
      final pay = service.computeVacationPay(
        frequency: PayrollFrequency.monthly,
        lastBaseSalary: 1000.0,
        hasVariableComponentsOrRecentRaise: true,
        last11MonthsOrdinaryEarnings: List.filled(11, 1200.0), // Promedio mayor
        last11MonthsExtraordinaryEarnings: List.filled(11, 0.0),
        ordinaryWorkdaysServedLast11Months: 242,
        vacationDaysToPay: 30.0,
      );
      
      // Promedio = 1200, último base = 1000 => usar 1200
      expect(pay, 1200.0);
    });
    
    test('Mensual con variables: selecciona el mayor (último salario)', () {
      final pay = service.computeVacationPay(
        frequency: PayrollFrequency.monthly,
        lastBaseSalary: 1500.0,
        hasVariableComponentsOrRecentRaise: true,
        last11MonthsOrdinaryEarnings: List.filled(11, 1200.0),
        last11MonthsExtraordinaryEarnings: List.filled(11, 0.0),
        ordinaryWorkdaysServedLast11Months: 242,
        vacationDaysToPay: 30.0,
      );
      
      // Promedio = 1200, último base = 1500 => usar 1500
      expect(pay, 1500.0);
    });
    
    test('Pago proporcional: 15 días = 50% del full', () {
      final pay = service.computeVacationPay(
        frequency: PayrollFrequency.monthly,
        lastBaseSalary: 1000.0,
        hasVariableComponentsOrRecentRaise: false,
        last11MonthsOrdinaryEarnings: List.filled(11, 1000.0),
        last11MonthsExtraordinaryEarnings: List.filled(11, 0.0),
        ordinaryWorkdaysServedLast11Months: 242,
        vacationDaysToPay: 15.0,
      );
      
      // 1000 * (15/30) = 500
      expect(pay, 500.0);
    });
  });

  group('Vacation Payment - Weekly', () {
    test('Semanal: 4.333 semanas para 30 días', () {
      final pay = service.computeVacationPay(
        frequency: PayrollFrequency.weekly,
        lastBaseSalary: 230.0, // ~1000 mensual / 4.333
        hasVariableComponentsOrRecentRaise: false,
        last11MonthsOrdinaryEarnings: List.filled(11, 1000.0),
        last11MonthsExtraordinaryEarnings: List.filled(11, 0.0),
        ordinaryWorkdaysServedLast11Months: 242,
        vacationDaysToPay: 30.0,
      );
      
      // 230 * 4.333333 * (30/30) ≈ 996.67
      expect(pay, closeTo(996.67, 1.0));
    });
  });

  group('Vacation Payment - Daily/Hourly', () {
    test('Diario: tasa diaria × días', () {
      final pay = service.computeVacationPay(
        frequency: PayrollFrequency.daily,
        lastBaseSalary: 45.0,
        hasVariableComponentsOrRecentRaise: false,
        last11MonthsOrdinaryEarnings: List.filled(11, 1000.0),
        last11MonthsExtraordinaryEarnings: List.filled(11, 0.0),
        ordinaryWorkdaysServedLast11Months: 242, // ~22 días/mes
        vacationDaysToPay: 10.0,
      );
      
      // total11 = 11000, dailyRate = 11000/242 ≈ 45.45
      // pago = 45.45 * 10 ≈ 454.5
      expect(pay, closeTo(454.5, 5.0));
    });
  });

  group('Calculation Method Detection', () {
    test('Identifica método: salario base sin variables', () {
      final method = service.getCalculationMethod(
        frequency: PayrollFrequency.monthly,
        hasVariableComponentsOrRecentRaise: false,
        lastBaseSalary: 1000.0,
        avgMonthly11: 1200.0,
      );
      
      expect(method, 'Salario base (sin variables)');
    });
    
    test('Identifica método: tasa diaria', () {
      final method = service.getCalculationMethod(
        frequency: PayrollFrequency.daily,
        hasVariableComponentsOrRecentRaise: false,
        lastBaseSalary: 45.0,
        avgMonthly11: 1000.0,
      );
      
      expect(method, contains('Tasa diaria'));
    });
    
    test('Identifica método: más favorable (promedio)', () {
      final method = service.getCalculationMethod(
        frequency: PayrollFrequency.monthly,
        hasVariableComponentsOrRecentRaise: true,
        lastBaseSalary: 1000.0,
        avgMonthly11: 1200.0,
      );
      
      expect(method, contains('Promedio 11 meses'));
    });
  });
}
