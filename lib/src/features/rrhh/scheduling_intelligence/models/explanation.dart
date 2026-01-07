/// Human readable explanation for a decision
class Explanation {
  final String summary; // 1-2 lines summary
  final List<String> reasons; // Bullet points
  final double scoreChange; // Impact on score (+5, -10)
  final bool improvedFairness; // Does this help fairness?

  Explanation({
    required this.summary,
    required this.reasons,
    this.scoreChange = 0,
    this.improvedFairness = false,
  });
}
