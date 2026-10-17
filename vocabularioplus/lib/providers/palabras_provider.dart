import 'package:flutter/foundation.dart';
import '../models/palabra.dart';
import '../services/database_service.dart';

enum FiltroPalabras { todas, recientes, favoritas }

class PalabrasProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Palabra> _palabras = [];
  FiltroPalabras _filtro = FiltroPalabras.todas;
  String _terminoBusqueda = '';
  bool _cargando = false;
  String? _error;

  List<Palabra> get palabras => _aplicarFiltroYBusqueda();
  FiltroPalabras get filtro => _filtro;
  String get terminoBusqueda => _terminoBusqueda;
  bool get cargando => _cargando;
  String? get error => _error;


  // * Para funcion PalabraAleatoria
  Palabra? _palabraActual;
  bool _revelada = false;

  Palabra? get palabraActual => _palabraActual;
  bool get revelada => _revelada;



  List<Palabra> _aplicarFiltroYBusqueda() {
    var resultado = _palabras;

    if (_filtro == FiltroPalabras.favoritas) {
      resultado = resultado.where((p) => p.favorito).toList();
    } else if (_filtro == FiltroPalabras.recientes) {
      resultado = List.of(resultado)
        ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      resultado = resultado.take(10).toList();
    }

    if (_terminoBusqueda.isNotEmpty) {
      final termino = _terminoBusqueda.toLowerCase();
      resultado = resultado
          .where((p) =>
              p.palabra.toLowerCase().contains(termino) ||
              p.significado.toLowerCase().contains(termino))
          .toList();
    }

    return resultado;
  }

  Future<void> cargarPalabras() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _palabras = await _db.obtenerPalabras();
    } catch (e) {
      _error = 'No se pudieron cargar las palabras';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> agregar(Palabra palabra) async {
    await _db.insertarPalabra(palabra);
    await cargarPalabras();
  }

  Future<void> editar(Palabra palabra) async {
    await _db.actualizarPalabra(palabra);
    await cargarPalabras();
  }

  Future<void> eliminar(int id) async {
    await _db.eliminarPalabra(id);
    await cargarPalabras();
  }

  Future<void> alternarFavorito(Palabra palabra) async {
    final actualizada = palabra.copyWith(favorito: !palabra.favorito);
    await _db.actualizarPalabra(actualizada);
    await cargarPalabras();
  }

  void buscar(String termino) {
    _terminoBusqueda = termino;
    notifyListeners();
  }

  void filtrar(FiltroPalabras nuevoFiltro) {
    _filtro = nuevoFiltro;
    notifyListeners();
  }



  Future<void> cargarPalabraAleatoria({bool soloFavoritas = false}) async {
    _revelada = false;
    // _palabraActual = await _db.obtenerPalabraAleatoria(soloFavoritas: soloFavoritas);
    _palabraActual = await _db.obtenerPalabraPonderada(soloFavoritas: soloFavoritas);
    notifyListeners();
  }

  void revelarSignificado() {
    _revelada = true;
    notifyListeners();
    if (_palabraActual?.id != null) {
      _db.incrementarVecesVista(_palabraActual!.id!);
    }
  }

}