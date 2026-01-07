import 'decimo_models.dart';
import '../features/payroll/domain/payroll_constants.dart';

class DecimoLogic {
  static DecimoResultModel calculate(double totalEarnings) {
    double decimo = totalEarnings / 12.0;
    // Decimo pays 7.25% CSS, Exempt from SE and ISR (usually)
    double css = decimo * PayrollConstants.TASA_SS_DECIMO; 
    double net = decimo - css;
    
    return DecimoResultModel(
      totalEarnings: totalEarnings,
      decimoAmount: decimo,
      css: css,
      netDecimo: net,
    );
  }
}
