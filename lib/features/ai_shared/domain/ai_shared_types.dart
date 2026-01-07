enum AiFeatureType {
  products,
  contracts,
  processes,
  strategies
}

extension AiFeatureTypeExtension on AiFeatureType {
  String get label {
    switch (this) {
      case AiFeatureType.products:
        return 'IA PARA PRODUCTOS';
      case AiFeatureType.contracts:
        return 'IA PARA CONTRATOS';
      case AiFeatureType.processes:
        return 'IA PARA PROCESOS';
      case AiFeatureType.strategies:
        return 'IA PARA ESTRATEGIAS';
    }
  }

  String get subtitle {
    switch (this) {
      case AiFeatureType.products:
        return 'Descripciones profesionales para catálogos y ventas';
      case AiFeatureType.contracts:
        return 'Contratos legales validados para Panamá';
      case AiFeatureType.processes:
        return 'Manuales de procedimientos (SOP) profesionales';
      case AiFeatureType.strategies:
        return 'Planes de negocio y estrategias ejecutables';
    }
  }

  String get promptHint {
    switch (this) {
      case AiFeatureType.products:
        return 'Ej: Zapatos deportivos para running';
      case AiFeatureType.contracts:
        return 'Ej: Contrato de arrendamiento para local comercial';
      case AiFeatureType.processes:
        return 'Ej: Atención al cliente en restaurante';
      case AiFeatureType.strategies:
        return 'Ej: Campaña de ventas para Navidad 2025';
    }
  }

  String get instructions {
    switch (this) {
      case AiFeatureType.products:
        return '''📋 CÓMO FUNCIONA:
Escribe el nombre del producto o servicio que vendes. La IA creará una ficha técnica profesional con descripción persuasiva, beneficios y precio sugerido.

💡 EJEMPLOS REALES:
• "Servicio de limpieza comercial"
• "Hamburguesa gourmet con queso artesanal"
• "Paquete turístico a Bocas del Toro"''';
      case AiFeatureType.contracts:
        return '''📋 CÓMO FUNCIONA:
Indica el tipo de contrato que necesitas. La IA generará un documento profesional con todas las cláusulas legales de Panamá, listo para completar con tus datos.

💡 EJEMPLOS REALES:
• "Contrato de arrendamiento para apartamento"
• "Contrato laboral para cajero de tienda"
• "Contrato de servicios profesionales de diseño"''';
      case AiFeatureType.processes:
        return '''📋 CÓMO FUNCIONA:
Describe el proceso o procedimiento que quieres documentar. La IA creará un manual paso a paso (SOP) profesional para capacitar a tu equipo.

💡 EJEMPLOS REALES:
• "Apertura y cierre de caja en tienda"
• "Recepción de mercancía en bodega"
• "Manejo de quejas de clientes"''';
      case AiFeatureType.strategies:
        return '''📋 CÓMO FUNCIONA:
Describe tu objetivo de negocio. La IA creará un plan estratégico completo con análisis, tácticas, cronograma y KPIs.

💡 EJEMPLOS REALES:
• "Aumentar ventas 30% en próximos 3 meses"
• "Lanzar nuevo menú vegetariano"
• "Campaña de redes sociales para Black Friday"''';
    }
  }
}
