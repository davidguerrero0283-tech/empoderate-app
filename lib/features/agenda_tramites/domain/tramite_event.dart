// Domain Model: Tramite Event
// Represents a recurring or one-time administrative task/procedure

enum CategoriaEntidad {
  dgi,
  municipio,
  mitradel,
  css,
  minsa,
  otro;

  String get displayName {
    switch (this) {
      case CategoriaEntidad.dgi:
        return 'DGI';
      case CategoriaEntidad.municipio:
        return 'Municipio';
      case CategoriaEntidad.mitradel:
        return 'MITRADEL';
      case CategoriaEntidad.css:
        return 'CSS';
      case CategoriaEntidad.minsa:
        return 'MINSA';
      case CategoriaEntidad.otro:
        return 'Otro';
    }
  }
}

enum Periodicidad {
  unica,
  mensual,
  trimestral,
  semestral,
  anual,
  personalizada;

  String get displayName {
    switch (this) {
      case Periodicidad.unica:
        return 'Única';
      case Periodicidad.mensual:
        return 'Mensual';
      case Periodicidad.trimestral:
        return 'Trimestral';
      case Periodicidad.semestral:
        return 'Semestral';
      case Periodicidad.anual:
        return 'Anual';
      case Periodicidad.personalizada:
        return 'Personalizada';
    }
  }
}

enum EstadoTramite {
  pendiente,
  alDia,
  vencido;

  String get displayName {
    switch (this) {
      case EstadoTramite.pendiente:
        return 'Pendiente';
      case EstadoTramite.alDia:
        return 'Al día';
      case EstadoTramite.vencido:
        return 'Vencido';
    }
  }
}

class TramiteEvent {
  final String id;
  final String titulo;
  final CategoriaEntidad categoria;
  final String entidad;
  final String descripcion;
  final DateTime fechaInicio;
  final Periodicidad periodicidad;
  final int? cadaXDias;
  final DateTime proximaFecha;
  final int diasAnticipacionAlerta;
  final EstadoTramite estado;
  final String? notas;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? asociadoNegocioId;

  TramiteEvent({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.entidad,
    this.descripcion = '',
    required this.fechaInicio,
    required this.periodicidad,
    this.cadaXDias,
    required this.proximaFecha,
    this.diasAnticipacionAlerta = 7,
    required this.estado,
    this.notas,
    required this.createdAt,
    required this.updatedAt,
    this.asociadoNegocioId,
  });

  // Create copy with modifications
  TramiteEvent copyWith({
    String? id,
    String? titulo,
    CategoriaEntidad? categoria,
    String? entidad,
    String? descripcion,
    DateTime? fechaInicio,
    Periodicidad? periodicidad,
    int? cadaXDias,
    DateTime? proximaFecha,
    int? diasAnticipacionAlerta,
    EstadoTramite? estado,
    String? notas,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? asociadoNegocioId,
  }) {
    return TramiteEvent(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      categoria: categoria ?? this.categoria,
      entidad: entidad ?? this.entidad,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      periodicidad: periodicidad ?? this.periodicidad,
      cadaXDias: cadaXDias ?? this.cadaXDias,
      proximaFecha: proximaFecha ?? this.proximaFecha,
      diasAnticipacionAlerta: diasAnticipacionAlerta ?? this.diasAnticipacionAlerta,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      asociadoNegocioId: asociadoNegocioId ?? this.asociadoNegocioId,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'categoria': categoria.name,
      'entidad': entidad,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'periodicidad': periodicidad.name,
      'cadaXDias': cadaXDias,
      'proximaFecha': proximaFecha.toIso8601String(),
      'diasAnticipacionAlerta': diasAnticipacionAlerta,
      'estado': estado.name,
      'notas': notas,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'asociadoNegocioId': asociadoNegocioId,
    };
  }

  factory TramiteEvent.fromJson(Map<String, dynamic> json) {
    return TramiteEvent(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      categoria: CategoriaEntidad.values.firstWhere((e) => e.name == json['categoria']),
      entidad: json['entidad'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      periodicidad: Periodicidad.values.firstWhere((e) => e.name == json['periodicidad']),
      cadaXDias: json['cadaXDias'] as int?,
      proximaFecha: DateTime.parse(json['proximaFecha'] as String),
      diasAnticipacionAlerta: json['diasAnticipacionAlerta'] as int? ?? 7,
      estado: EstadoTramite.values.firstWhere((e) => e.name == json['estado']),
      notas: json['notas'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      asociadoNegocioId: json['asociadoNegocioId'] as String?,
    );
  }
}
