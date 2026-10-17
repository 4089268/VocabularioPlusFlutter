import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasAjustes {
  final bool notificacionesActivas;
  final int frecuenciaDiaria;
  final int horaDesde;
  final int horaHasta;
  final bool soloFavoritas;

  const PreferenciasAjustes({
    this.notificacionesActivas = false,
    this.frecuenciaDiaria = 3,
    this.horaDesde = 9,
    this.horaHasta = 21,
    this.soloFavoritas = false,
  });

  PreferenciasAjustes copyWith({
    bool? notificacionesActivas,
    int? frecuenciaDiaria,
    int? horaDesde,
    int? horaHasta,
    bool? soloFavoritas,
  }) {
    return PreferenciasAjustes(
      notificacionesActivas: notificacionesActivas ?? this.notificacionesActivas,
      frecuenciaDiaria: frecuenciaDiaria ?? this.frecuenciaDiaria,
      horaDesde: horaDesde ?? this.horaDesde,
      horaHasta: horaHasta ?? this.horaHasta,
      soloFavoritas: soloFavoritas ?? this.soloFavoritas,
    );
  }
}

class PreferenciasService {
  static const _kActivas = 'notificaciones_activas';
  static const _kFrecuencia = 'frecuencia_diaria';
  static const _kHoraDesde = 'hora_desde';
  static const _kHoraHasta = 'hora_hasta';
  static const _kSoloFavoritas = 'solo_favoritas';

  Future<PreferenciasAjustes> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferenciasAjustes(
      notificacionesActivas: prefs.getBool(_kActivas) ?? false,
      frecuenciaDiaria: prefs.getInt(_kFrecuencia) ?? 3,
      horaDesde: prefs.getInt(_kHoraDesde) ?? 9,
      horaHasta: prefs.getInt(_kHoraHasta) ?? 21,
      soloFavoritas: prefs.getBool(_kSoloFavoritas) ?? false,
    );
  }

  Future<void> guardar(PreferenciasAjustes p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kActivas, p.notificacionesActivas);
    await prefs.setInt(_kFrecuencia, p.frecuenciaDiaria);
    await prefs.setInt(_kHoraDesde, p.horaDesde);
    await prefs.setInt(_kHoraHasta, p.horaHasta);
    await prefs.setBool(_kSoloFavoritas, p.soloFavoritas);
  }
}