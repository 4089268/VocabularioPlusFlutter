class Palabra
{
  final int? id;
  final String palabra;
  final String tipo; // 'sust', 'adj', 'verbo', 'adv'
  final String significado;
  final String? ejemplo;
  final bool favorito;
  final bool incluirNotificaciones;
  final DateTime fechaCreacion;
  final int vecesVista;

  Palabra({
    this.id,
    required this.palabra,
    required this.tipo,
    required this.significado,
    this.ejemplo,
    this.favorito = false,
    this.incluirNotificaciones = true,
    DateTime? fechaCrea,
    this.vecesVista = 0,
  }) : fechaCreacion = fechaCrea ?? DateTime.now();

  Map<String, dynamic> toMap()
  {
    return
    {
      'id': id,
      'palabra': palabra,
      'tipo': tipo,
      'significado': significado,
      'ejemplo': ejemplo,
      'favorito': favorito,
      'incluirNotificaciones': incluirNotificaciones ? 1 : 0,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'vecesVista': vecesVista
    };
  }

  factory Palabra.fromMap(Map<String,dynamic> map)
  {
    return Palabra(
      id: map['id'] as int?,
      palabra: map['palabra'] as String,
      tipo: map['tipo'] as String,
      significado: map['significado'] as String,
      ejemplo: map['ejemplo'] as String?,
      favorito: (map['favorito'] as int) == 1,
      incluirNotificaciones: (map['incluirNotificaciones'] as int) == 1,
      fechaCrea: DateTime.parse(map['fechaCreacion'] as String),
      vecesVista: map['vecesVista'] as int,
    );
  }

  Palabra copyWith({
    int? id,
    String? palabra,
    String? tipo,
    String? significado,
    String? ejemplo,
    bool? favorito,
    bool? incluirNotificaciones,
    DateTime? fechaCreacion,
    int? vecesVista,
  }) {
    return Palabra(
      id: id ?? this.id,
      palabra: palabra ?? this.palabra,
      tipo: tipo ?? this.tipo,
      significado: significado ?? this.significado,
      ejemplo: ejemplo ?? this.ejemplo,
      favorito: favorito ?? this.favorito,
      incluirNotificaciones: incluirNotificaciones ?? this.incluirNotificaciones,
      fechaCrea: fechaCreacion ?? this.fechaCreacion,
      vecesVista: vecesVista ?? this.vecesVista,
    );
  }
}