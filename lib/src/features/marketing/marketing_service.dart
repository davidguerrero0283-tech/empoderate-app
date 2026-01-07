import 'dart:math';
import 'marketing_models.dart';

class MarketingService {
  // Singleton pattern
  static final MarketingService _instance = MarketingService._internal();
  factory MarketingService() => _instance;
  MarketingService._internal();

  // Mock Data Store
  final List<MarketingCampaign> _campaigns = [
    MarketingCampaign(
      id: 'c1',
      name: 'Lanzamiento Verano',
      platform: 'Instagram',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      budget: 500.0,
      spent: 320.50,
      impressions: 15400,
      clicks: 850,
      conversions: 42,
      status: CampaignStatus.active,
    ),
    MarketingCampaign(
      id: 'c2',
      name: 'Retargeting Carrito',
      platform: 'Facebook',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      budget: 200.0,
      spent: 145.00,
      impressions: 5200,
      clicks: 120,
      conversions: 15,
      status: CampaignStatus.active,
    ),
    MarketingCampaign(
      id: 'c3',
      name: 'Google Search Brand',
      platform: 'Google',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      budget: 1000.0,
      spent: 980.00,
      impressions: 25000,
      clicks: 1500,
      conversions: 180,
      status: CampaignStatus.paused,
    ),
    MarketingCampaign(
      id: 'c4',
      name: 'TikTok Viral Challenge',
      platform: 'TikTok',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      budget: 300.0,
      spent: 50.00,
      impressions: 45000,
      clicks: 2500,
      conversions: 5, // High traffic, low conversion initially
      status: CampaignStatus.active,
    ),
  ];

  // Get all campaigns
  List<MarketingCampaign> getCampaigns() {
    return List.from(_campaigns);
  }

  // Get campaigns by status
  List<MarketingCampaign> getCampaignsByStatus(CampaignStatus status) {
    return _campaigns.where((c) => c.status == status).toList();
  }

  // Create Campaign
  void addCampaign(MarketingCampaign campaign) {
    _campaigns.add(campaign);
  }

  // Update Campaign
  void updateCampaign(MarketingCampaign campaign) {
    final index = _campaigns.indexWhere((c) => c.id == campaign.id);
    if (index != -1) {
      _campaigns[index] = campaign;
    }
  }

  // Delete Campaign
  void deleteCampaign(String id) {
    _campaigns.removeWhere((c) => c.id == id);
  }

  // Calculate Overall Dashboard Metrics
  Map<String, dynamic> getOverallMetrics() {
    double totalSpend = 0;
    int totalImpressions = 0;
    int totalConversions = 0;

    for (var c in _campaigns) {
      totalSpend += c.spent;
      totalImpressions += c.impressions;
      totalConversions += c.conversions;
    }

    double avgCPA = totalConversions > 0 ? totalSpend / totalConversions : 0.0;

    return {
      'totalSpend': totalSpend,
      'totalImpressions': totalImpressions,
      'totalConversions': totalConversions,
      'avgCPA': avgCPA,
    };
  }

  // Mock Trend Data generator
  List<MarketingMetric> getRecentPerformance() {
    final List<MarketingMetric> data = [];
    final now = DateTime.now();
    final random = Random();
    
    for (int i = 6; i >= 0; i--) {
      data.add(MarketingMetric(
        date: now.subtract(Duration(days: i)),
        newLeads: 5 + random.nextInt(15), // 5-20 leads
        sales: 1 + random.nextInt(5), // 1-6 sales
        revenue: (1 + random.nextInt(5)) * 49.99, // Approx revenue
      ));
    }
    return data;
  }

  // Mock Generator: Content Ideas (PRO - Enhanced Simulation)
  Future<List<Map<String, dynamic>>> generateContentIdeas({
    required String topic, 
    required String platform,
    required String tone,
    required String goal,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate AI delay
    
    final random = Random();
    final List<Map<String, dynamic>> results = [];

    // Generators for varied content
    for (int i = 0; i < 4; i++) {
      results.add(_generateSingleIdea(topic, platform, tone, goal, random, i));
    }
    return results;
  }

  Map<String, dynamic> _generateSingleIdea(String topic, String platform, String tone, String goal, Random random, int index) {
    // 1. Determine Style based on Index/Tone
    String title = "";
    String hookTemplate = "";
    String scriptTemplate = "";
    String visualTemplate = "";

    // Tone Modifiers
    String emoji = "💡";
    if (tone == 'Divertido') emoji = ["😂", "🤣", "🤪", "👀"].elementAt(random.nextInt(4));
    if (tone == 'Autoridad') emoji = ["📈", "🧠", "👨‍🏫", "🔥"].elementAt(random.nextInt(4));
    if (tone == 'Empático') emoji = ["❤️", "🙏", "✨", "🫂"].elementAt(random.nextInt(4));

    // Goal Modifiers (Call to Action)
    String cta = "";
    if (goal == 'Ventas') cta = ["Comenta 'INFO' y te envío el link", "Ve al link de mi perfil", "Aprovecha la oferta por 24h"].elementAt(random.nextInt(3));
    if (goal == 'Viralidad') cta = ["Comparte esto con tu amigo emprendedor", "¿Estás de acuerdo? Te leo", "Guárdalo para que no se te olvide"].elementAt(random.nextInt(3));
    if (goal == 'Comunidad') cta = ["Cuéntame tu experiencia abajo", "¿Qué opinas tú?", "Etiqueta a quien necesite leer esto"].elementAt(random.nextInt(3));

    // Strategies (Varied by index)
    if (index == 0) {
      title = "El Mito Común ($tone)";
      visualTemplate = "🎥 **Visual:** Tú negando con la cabeza o mostrando un 'Antes vs Después'. Texto flotante: 'Deja de hacer esto'.";
      if (tone == 'Divertido') {
         hookTemplate = "Si sigues creyendo que $topic es difícil, tengo un puente para venderte. $emoji";
         scriptTemplate = "¡Basta ya! 😂 La gente cree que para dominar $topic necesitas magia. Mentira. Solo necesitas sentido común. Aquí te explico por qué...";
      } else {
         hookTemplate = "El 90% de las personas fallan en $topic por esta simple razón.";
         scriptTemplate = "Seguro te han dicho que $topic es complicado. La realidad es diferente. El verdadero secreto está en la constancia. Escucha esto...";
      }
    } else if (index == 1) {
      title = "Paso a Paso Rápido";
      visualTemplate = "🎥 **Visual:** Grabación de pantalla o tus manos trabajando (POV). Cortes rápidos.";
      hookTemplate = "¿Quieres dominar $topic en 30 segundos? Mira esto.";
      scriptTemplate = "Paso 1: Olvida lo que sabías. Paso 2: Enfócate en lo básico. Paso 3: Ejecuta hoy mismo. ¡Es así de simple! $emoji No te compliques.";
    } else if (index == 2) {
      title = "Historia / Storytime";
      visualTemplate = "🎥 **Visual:** Hablando a cámara tomando café, ambiente relajado.";
      hookTemplate = "Hace un año, $topic era mi peor pesadilla.";
      scriptTemplate = "Estaba a punto de rendirme. Nada funcionaba. Hasta que cambié una pequeña cosa... $emoji Hoy, los resultados son increíbles. Te cuento mi secreto.";
    } else {
      title = "Dato Curioso / Sabías Que";
      visualTemplate = "🎥 **Visual:** Fondo verde con una noticia o gráfico detrás de ti.";
      hookTemplate = "¿Sabías que $topic puede cambiar tu negocio hoy mismo?";
      scriptTemplate = "Pocos hablan de esto, pero $topic es la clave oculta de los grandes. $emoji Si lo aplicas mañana, verás la diferencia. Aquí están los datos...";
    }

    return {
      'title': title,
      'visual_hook': visualTemplate,
      'script_body': 'Script: "$hookTemplate $scriptTemplate"\n\n👉 CTA: $cta',
      'hashtags': '#$topic #tips #$tone #${goal.toLowerCase()} #crecimiento',
      'pro_tip': _getProTip(random),
      'goal_match': 'Optimizado para $goal'
    };
  }

  String _getProTip(Random random) {
    const tips = [
      "Usa audio en tendencia para mayor alcance.",
      "Corta los silencios para mantener el ritmo rápido.",
      "Añade subtítulos dinámicos, la gente ve videos sin sonido.",
      "Usa buena iluminación, incluso si es natural.",
      "Interactúa con los primeros comentarios en los primeros 15 min."
    ];
    return tips[random.nextInt(tips.length)];
  }

  // Mock Generator: Avatar Profile
  Future<Map<String, dynamic>> generateAvatarProfile(Map<String, String> inputs) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate AI delay
    
    String age = inputs['age'] ?? '30';
    String gender = inputs['gender'] ?? 'General';
    String interests = inputs['interests'] ?? 'Negocios';
    
    return {
      'name': 'Avatar Generado ($gender, $age años)',
      'summary': 'Este cliente busca soluciones rápidas en $interests. Valora la eficiencia y está dispuesto a invertir si ve resultados claros.',
      'painPoints': [
        'No tiene suficiente tiempo para investigar a fondo.',
        'Ha tenido malas experiencias previas con servicios similares.',
        'Le preocupa el retorno de inversión a corto plazo.'
      ],
      'desires': [
        'Automatizar procesos repetitivos.',
        'Sentirse en control de su crecimiento.',
        'Reconocimiento en su nicho de mercado (Relacionado a $interests).'
      ],
      'objections': [
        '¿Es demasiado complicado de implementar?',
        '¿Realmente funcionará para mi caso específico?'
      ]
    };
  }
  // Funnel Scenarios
  final List<Map<String, dynamic>> _savedScenarios = [];

  void saveFunnelScenario(String name, Map<String, dynamic> data) {
    _savedScenarios.add({
      'name': name,
      'date': DateTime.now(),
      'data': data,
    });
  }

  List<Map<String, dynamic>> getSavedScenarios() => List.from(_savedScenarios);

  // Funnel Trend Data (Mock)
  List<Map<String, dynamic>> getFunnelHistory() {
    final now = DateTime.now();
    final random = Random();
    
    return List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      return {
        'date': date,
        'leads': 10 + random.nextInt(20),
        'sales': 1 + random.nextInt(5),
      };
    });
  }
}
