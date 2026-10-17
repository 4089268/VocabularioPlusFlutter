import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/palabra.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'vocabulario_plus.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE palabras(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            palabra TEXT NOT NULL,
            tipo TEXT NOT NULL,
            significado TEXT NOT NULL,
            ejemplo TEXT,
            favorito INTEGER NOT NULL DEFAULT 0,
            incluirNotificaciones INTEGER NOT NULL DEFAULT 1,
            fechaCreacion TEXT NOT NULL,
            vecesVista INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  
  // --- CRUD ---

  Future<int> insertarPalabra(Palabra palabra) async {
    final db = await database;
    return db.insert('palabras', palabra.toMap()..remove('id'));
  }

  Future<List<Palabra>> obtenerPalabras() async {
    final db = await database;
    final maps = await db.query('palabras', orderBy: 'fechaCreacion DESC');
    return maps.map((m) => Palabra.fromMap(m)).toList();
  }

  Future<int> actualizarPalabra(Palabra palabra) async {
    final db = await database;
    return db.update(
      'palabras',
      palabra.toMap(),
      where: 'id = ?',
      whereArgs: [palabra.id],
    );
  }

  Future<int> eliminarPalabra(int id) async {
    final db = await database;
    return db.delete('palabras', where: 'id = ?', whereArgs: [id]);
  }


  // --- Consultas ---

  Future<List<Palabra>> buscarPalabras(String termino) async {
    final db = await database;
    final maps = await db.query(
      'palabras',
      where: 'palabra LIKE ? OR significado LIKE ?',
      whereArgs: ['%$termino%', '%$termino%'],
      orderBy: 'fechaCreacion DESC',
    );
    return maps.map((m) => Palabra.fromMap(m)).toList();
  }

  Future<List<Palabra>> obtenerFavoritas() async {
    final db = await database;
    final maps = await db.query(
      'palabras',
      where: 'favorito = 1',
      orderBy: 'fechaCreacion DESC',
    );
    return maps.map((m) => Palabra.fromMap(m)).toList();
  }

  Future<Palabra?> obtenerPalabraAleatoria({bool soloFavoritas = false}) async {
    final db = await database;
    final where = soloFavoritas ? 'WHERE favorito = 1' : '';
    final maps = await db.rawQuery(
      'SELECT * FROM palabras $where ORDER BY RANDOM() LIMIT 1',
    );
    if (maps.isEmpty) return null;
    return Palabra.fromMap(maps.first);
  }

  Future<void> incrementarVecesVista(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE palabras SET vecesVista = vecesVista + 1 WHERE id = ?',
      [id],
    );
  }

  Future<Palabra?> obtenerPalabraPonderada({bool soloFavoritas = false}) async {
    final db = await database;
    final where = soloFavoritas ? 'WHERE favorito = 1' : '';
    final maps = await db.rawQuery('SELECT * FROM palabras $where');

    if (maps.isEmpty) return null;

    final palabras = maps.map((m) => Palabra.fromMap(m)).toList();

    // Peso inversamente proporcional a vecesVista: las menos vistas pesan más.
    final pesos = palabras.map((p) => 1.0 / (p.vecesVista + 1)).toList();
    final pesoTotal = pesos.reduce((a, b) => a + b);

    final random = Random().nextDouble() * pesoTotal;
    var acumulado = 0.0;

    for (var i = 0; i < palabras.length; i++) {
      acumulado += pesos[i];
      if (random <= acumulado) return palabras[i];
    }

    return palabras.last; // fallback por redondeo flotante
  }
}