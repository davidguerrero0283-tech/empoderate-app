/// Servicio para cálculo de vacaciones según ley panameña (Art. 54 Código de Trabajo)
class VacationCalculatorService {
  /// Calcula días de vacaciones devengados
  /// Regla: 1 día por cada 11 días de servicio (30 días cada 11 meses)
  double computeVacationDaysAccrued({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // Días de servicio (inclusivo)
    final serviceDays = endDate.difference(startDate).inDays + 1;
    
    // 1 día de vacaciones por cada 11 días de servicio
    final vacationDays = serviceDays / 11.0;
    
    // Clamp a 30 días máximo por periodo anual
    return vacationDays > 30.0 ? 30.0 : vacationDays;
  }
  
  /// Calcula pago de vacaciones según frecuencia de pago y presencia de componentes variables
  double computeVacationPay({
    required PayrollFrequency frequency,
    required double lastBaseSalary,
    required bool hasVariableComponentsOrRecentRaise,
    required List<double> last11MonthsOrdinaryEarnings,
    required List<double> last11MonthsExtraordinaryEarnings,
    required int ordinaryWorkdaysServedLast11Months,
    required double vacationDaysToPay,
  }) {
    // Calcular total de earnings de 11 meses
    final ordinaryTotal = last11MonthsOrdinaryEarnings.fold(0.0, (a, b) => a + b);
    final extraordinaryTotal = last11MonthsExtraordinaryEarnings.fold(0.0, (a, b) => a + b);
    final total11 = ordinaryTotal + extraordinaryTotal;
    final avgMonthly11 = total11 / 11.0;
    
    double fullVacationPay;
    
    switch (frequency) {
      case PayrollFrequency.monthly:
      case PayrollFrequency.biweekly:
        // Convertir biweekly a mensual (×2.1667 = 52 semanas / 12 meses / 2)
        final baseMonthly = frequency == PayrollFrequency.biweekly 
            ? lastBaseSalary * 2.166667 
            : lastBaseSalary;
        
        // Si hay variables, usar el MÁS FAVORABLE
        fullVacationPay = hasVariableComponentsOrRecentRaise
            ? (baseMonthly > avgMonthly11 ? baseMonthly : avgMonthly11)
            : baseMonthly;
        break;
      
      case PayrollFrequency.weekly:
        // 4 semanas + 1/3 = 4.333333 semanas
        final baseFull = lastBaseSalary * 4.333333;
        
        fullVacationPay = hasVariableComponentsOrRecentRaise
            ? (baseFull > avgMonthly11 ? baseFull : avgMonthly11)
            : baseFull;
        break;
      
      case PayrollFrequency.daily:
      case PayrollFrequency.hourly:
        if (ordinaryWorkdaysServedLast11Months > 0) {
          // Tasa diaria promedio
          final dailyRateAvg = total11 / ordinaryWorkdaysServedLast11Months;
          
          // Comparar con último mes si disponible (más favorable)
          final lastMonthTotal = (last11MonthsOrdinaryEarnings.isNotEmpty 
              ? last11MonthsOrdinaryEarnings.last 
              : 0.0) + 
              (last11MonthsExtraordinaryEarnings.isNotEmpty 
                  ? last11MonthsExtraordinaryEarnings.last 
                  : 0.0);
          
          // Estimar días del último mes (~22 días laborables)
          final lastMonthDays = ordinaryWorkdaysServedLast11Months ~/ 11;
          final dailyRateLastMonth = lastMonthDays > 0 
              ? lastMonthTotal / lastMonthDays 
              : 0.0;
          
          // Usar el más favorable
          final dailyRate = dailyRateAvg > dailyRateLastMonth 
              ? dailyRateAvg 
              : dailyRateLastMonth;
          
          // Pago directo: tasa diaria × días de vacaciones
          return dailyRate * vacationDaysToPay;
        }
        return 0.0;
    }
    
    // Pago proporcional para otros casos
    return fullVacationPay * (vacationDaysToPay / 30.0);
  }
  
  /// Determina el método de cálculo usado
  String getCalculationMethod({
    required PayrollFrequency frequency,
    required bool hasVariableComponentsOrRecentRaise,
    required double lastBaseSalary,
    required double avgMonthly11,
  }) {
    if (frequency == PayrollFrequency.daily || frequency == PayrollFrequency.hourly) {
      return 'Tasa diaria (Art. 54 - pago por día/hora)';
    }
    
    if (!hasVariableComponentsOrRecentRaise) {
      return 'Salario base (sin variables)';
    }
    
    final baseMonthly = frequency == PayrollFrequency.biweekly 
        ? lastBaseSalary * 2.166667 
        : (frequency == PayrollFrequency.weekly 
            ? lastBaseSalary * 4.333333 
            : lastBaseSalary);
    
    return baseMonthly > avgMonthly11
        ? 'Último salario base (más favorable)'
        : 'Promedio 11 meses (más favorable)';
  }
}

/// Frecuencia de pago de nómina
enum PayrollFrequency {
  monthly,
  biweekly,
  weekly,
  daily,
  hourly,
}
