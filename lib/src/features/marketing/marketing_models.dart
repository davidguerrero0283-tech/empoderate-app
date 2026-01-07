enum CampaignStatus { active, paused, completed, draft }

class MarketingCampaign {
  final String id;
  final String name;
  final String platform; // 'Facebook', 'Instagram', 'Google', 'TikTok', 'Email'
  final DateTime startDate;
  final double budget;
  final double spent;
  final int impressions;
  final int clicks;
  final int conversions;
  final CampaignStatus status;

  const MarketingCampaign({
    required this.id,
    required this.name,
    required this.platform,
    required this.startDate,
    required this.budget,
    required this.spent,
    required this.impressions,
    required this.clicks,
    required this.conversions,
    required this.status,
  });

  // Computed Metrics
  double get clickThroughRate => impressions > 0 ? (clicks / impressions) * 100 : 0.0;
  double get conversionRate => clicks > 0 ? (conversions / clicks) * 100 : 0.0;
  double get costPerClick => clicks > 0 ? spent / clicks : 0.0;
  double get costPerAcquisition => conversions > 0 ? spent / conversions : 0.0;
  double get roi => spent > 0 ? ((conversions * 50) - spent) / spent * 100 : 0.0; // Mock: Assume $50 value per conversion
}

class MarketingMetric {
  final DateTime date;
  final int newLeads;
  final int sales;
  final double revenue;

  const MarketingMetric({
    required this.date,
    required this.newLeads,
    required this.sales,
    required this.revenue,
  });
}
