/// Constantes de API Endpoints para Cloud Functions
///
/// Todos los endpoints de las Cloud Functions de Firebase
/// están centralizados aquí para fácil mantenimiento.

class ApiEndpoints {
  ApiEndpoints._();
  
  // Base path
  static const String _api = '/api';
  
  // ============================================
  // Health & Status
  // ============================================
  static const String health = '$_api/health';
  
  // ============================================
  // AI Endpoints
  // ============================================
  static const String aiChat = '$_api/ai/chat';
  static const String aiUsage = '$_api/ai/usage';
  
  // ============================================
  // Payment Endpoints
  // ============================================
  static const String paymentsCreate = '$_api/payments/create-checkout';
  static const String paymentsWebhook = '$_api/payments/webhook';
  static const String paymentsStatus = '$_api/payments/status';
  
  // ============================================
  // Subscription Endpoints
  // ============================================
  static const String subscriptionStatus = '$_api/subscription/status';
  static const String subscriptionCancel = '$_api/subscription/cancel';
  
  // ============================================
  // User Management (Admin)
  // ============================================
  static const String usersStats = '$_api/users/stats';
  static const String usersUpdate = '$_api/users/update';
}
