/// Constantes generales de la aplicación

class AppConstants {
  AppConstants._();
  
  // ============================================
  // App Info
  // ============================================
  static const String appName = 'Empodérate';
  static const String appVersion = '1.0.0';
  
  // ============================================
  // Subscription Plans
  // ============================================
  static const String planFree = 'free';
  static const String planCrecimiento = 'crecimiento';
  static const String planPro = 'pro';
  static const String planEmpresarial = 'empresarial';
  
  static const List<String> allPlans = [
    planFree,
    planCrecimiento,
    planPro,
    planEmpresarial,
  ];
  
  // ============================================
  // AI Limits por Plan
  // ============================================
  static const Map<String, int> aiDailyLimits = {
    planFree: 5,            // 5 requests/day
    planCrecimiento: 50,    // 50 requests/day
    planPro: 200,           // 200 requests/day
    planEmpresarial: 1000,  // 1000 requests/day
  };
  
  // ============================================
  // Payment Providers
  // ============================================
  static const String providerTwoCheckout = '2checkout';
  static const String providerPayPal = 'paypal';
  
  // ============================================
  // Storage
  // ============================================
  static const String storageKeyTheme = 'theme_mode';
  static const String storageKeyLanguage = 'language';
  static const String storageKeyOnboardingComplete = 'onboarding_complete';
  
  // ============================================
  // Timeouts
  // ============================================
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration aiTimeout = Duration(seconds: 60);
  
  // ============================================
  // URLs
  // ============================================
  static const String termsUrl = 'https://empoderate.com/terminos';
  static const String privacyUrl = 'https://empoderate.com/privacidad';
  static const String supportEmail = 'soporte@empoderate.com';
}
