class PayrollDeductionsService {
  // Rates 2024 Panama
  static const double rateCSS = 0.0975; // 9.75%
  static const double rateSE = 0.0125;  // 1.25%
  
  /// Calculates deductions for a given amounts
  PayrollDeductions calculate({
    required double grossAmount,
    bool applyCSS = true,
    bool applySE = true,
    bool applyISR = false,
    double otherDeductions = 0.0,
    double isrAmount = 0.0, // Manual ISR override or calculated if needed
  }) {
    double css = 0.0;
    double se = 0.0;
    
    if (applyCSS) {
      css = (grossAmount * rateCSS);
    }
    
    if (applySE) {
      se = (grossAmount * rateSE);
    }
    
    // ISR logic is complex (progressive tables), usually calculated on monthly projection.
    // For this demo/beta, we allow manual entry or simple toggle (if toggle, we assume 0 unless logic added)
    // We will use isrAmount if provided, otherwise 0 for now unless we implement full ISR table.
    double isr = applyISR ? isrAmount : 0.0;
    
    double totalDeductions = css + se + isr + otherDeductions;
    double netAmount = grossAmount - totalDeductions;
    
    return PayrollDeductions(
      css: _round(css),
      se: _round(se),
      isr: _round(isr),
      other: _round(otherDeductions),
      totalDeductions: _round(totalDeductions),
      netAmount: _round(netAmount),
    );
  }
  
  double _round(double val) {
    return double.parse(val.toStringAsFixed(2));
  }
}

class PayrollDeductions {
  final double css;
  final double se;
  final double isr;
  final double other;
  final double totalDeductions;
  final double netAmount;

  PayrollDeductions({
    required this.css,
    required this.se,
    required this.isr,
    required this.other,
    required this.totalDeductions,
    required this.netAmount,
  });
}
