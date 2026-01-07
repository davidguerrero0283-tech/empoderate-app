class ThirteenthMonthService {
  /// Standard Décimo is Total Earnings / 12 (8.33%)
  double computeDecimo({required double totalEarnings}) {
    return totalEarnings / 12.0;
  }

  /// Calculates the proportional décimo based on estimated daily rate and days
  double computeDecimoFromDays({required double dailyRate, required int days}) {
    return dailyRate * (days / 12.0); 
  }
}
