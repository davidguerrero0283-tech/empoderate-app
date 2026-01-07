class BusinessProfile {
  String nombre;
  String ruc; // New field
  String? logoBase64; // Company logo in Base64 format (optional)
  String? website; // Business website URL (optional)
  String rubro;
  String actividad;
  DateTime fechaInicio;
  String regimenFiscal;
  String municipio;
  String tipoFacturacion;
  String frecuenciaDeclaraciones;

  BusinessProfile({
    required this.nombre,
    required this.ruc,
    this.logoBase64,
    this.website,
    required this.rubro,
    required this.actividad,
    required this.fechaInicio,
    required this.regimenFiscal,
    required this.municipio,
    required this.tipoFacturacion,
    required this.frecuenciaDeclaraciones,
  });

  // Serialization
  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'ruc': ruc,
    'logoBase64': logoBase64,
    'website': website,
    'rubro': rubro,
    'actividad': actividad,
    'fechaInicio': fechaInicio.toIso8601String(),
    'regimenFiscal': regimenFiscal,
    'municipio': municipio,
    'tipoFacturacion': tipoFacturacion,
    'frecuenciaDeclaraciones': frecuenciaDeclaraciones,
  };

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      nombre: json['nombre'] ?? '',
      ruc: json['ruc'] ?? '',
      logoBase64: json['logoBase64'],
      website: json['website'],
      rubro: json['rubro'] ?? 'Otros',
      actividad: json['actividad'] ?? '',
      fechaInicio: json['fechaInicio'] != null ? DateTime.parse(json['fechaInicio']) : DateTime.now(),
      regimenFiscal: json['regimenFiscal'] ?? 'Persona Natural',
      municipio: json['municipio'] ?? '',
      tipoFacturacion: json['tipoFacturacion'] ?? 'Manual',
      frecuenciaDeclaraciones: json['frecuenciaDeclaraciones'] ?? 'Mensual',
    );
  }
}

class BusinessReminder {
  String id;
  String titulo;
  String descripcion;
  DateTime fecha;
  bool completado;
  BusinessReminder({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    this.completado = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'fecha': fecha.toIso8601String(),
    'completado': completado,
  };

  factory BusinessReminder.fromJson(Map<String, dynamic> json) => BusinessReminder(
    id: json['id'],
    titulo: json['titulo'],
    descripcion: json['descripcion'],
    fecha: DateTime.parse(json['fecha']),
    completado: json['completado'] ?? false,
  );
}
