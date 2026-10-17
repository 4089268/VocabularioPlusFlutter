import 'package:flutter/material.dart';
import 'package:vocabularioplus/providers/palabras_provider.dart';
import 'package:vocabularioplus/services/notification_service.dart';
import 'package:vocabularioplus/services/preferences_service.dart';

class AjustesProvider extends ChangeNotifier {
  final PreferenciasService _prefsService = PreferenciasService();
  final NotificationService _notifService = NotificationService();

  PreferenciasAjustes _preferencias = const PreferenciasAjustes();
  bool _cargando = true;

  PreferenciasAjustes get preferencias => _preferencias;
  bool get cargando => _cargando;

  Future<void> cargar() async {
    _preferencias = await _prefsService.cargar();
    _cargando = false;
    notifyListeners();
  }

  Future<bool> activarNotificaciones(bool activo, PalabrasProvider palabrasProvider) async {
    if(activo) {
      final concedido = await _notifService.solicitarPermisos();
      if(!concedido) return false;
    }

    _preferencias = _preferencias.copyWith(notificacionesActivas: activo);
    await _prefsService.guardar(_preferencias);
    notifyListeners();

    await _reprogramar(palabrasProvider);
    return true;
  }

  Future<void> actualizarFrecuencia(int frecuencia, PalabrasProvider palabrasProvider) async {
    _preferencias = _preferencias.copyWith(frecuenciaDiaria: frecuencia);
    await _prefsService.guardar(_preferencias);
    notifyListeners();
    await _reprogramar(palabrasProvider);
  }

  Future<void> actualizarHorario(int desde, int hasta, PalabrasProvider palabrasProvider) async {
    _preferencias = _preferencias.copyWith(horaDesde: desde, horaHasta: hasta);
    await _prefsService.guardar(_preferencias);
    notifyListeners();
    await _reprogramar(palabrasProvider);
  }

  Future<void> actualizarSoloFavoritas(bool soloFavoritas, PalabrasProvider palabrasProvider) async {
    _preferencias = _preferencias.copyWith(soloFavoritas: soloFavoritas);
    await _prefsService.guardar(_preferencias);
    notifyListeners();
    await _reprogramar(palabrasProvider);
  }

  Future<void> _reprogramar(PalabrasProvider palabrasProvider) async {
    if (!_preferencias.notificacionesActivas) {
      await _notifService.cancelarTodas();
      return;
    }

    var candidatas = palabrasProvider.palabras.where((p) => p.incluirNotificaciones).toList();
    if (_preferencias.soloFavoritas) {
      candidatas = candidatas.where((p) => p.favorito).toList();
    }

    await _notifService.programarNotificaciones(
      palabras: candidatas,
      frecuenciaDiaria: _preferencias.frecuenciaDiaria,
      horaDesde: _preferencias.horaDesde,
      horaHasta: _preferencias.horaHasta,
    );
  }

  /// Se llama al abrir la app para renovar el lote de notificaciones programadas.
  Future<void> reprogramarAlAbrir(PalabrasProvider palabrasProvider) async {
    if (_preferencias.notificacionesActivas) {
      await _reprogramar(palabrasProvider);
    }
  }
}