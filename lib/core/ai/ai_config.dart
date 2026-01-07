enum AiMode { mock, remote }

class AiConfig {
  static AiMode currentMode = AiMode.mock;
  
  // Future: Add backend URL or other global AI settings here
  static const String backendUrl = 'https://api.empoderate.app/v1/ai';
}
