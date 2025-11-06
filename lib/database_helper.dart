import 'dart:convert'; // Necessário para converter listas para JSON
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dados_receitas.dart'; // Importamos suas receitas para popular o banco

class DatabaseHelper {
  // Padrão Singleton
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase('rangolegal.db');
    return _database!;
  }

  Future<Database> _initDatabase(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // ATENÇÃO: A versão é 1. Se você desinstalar o app,
    // o _onCreate roda de novo.
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Cria TODAS as tabelas
  Future _onCreate(Database db, int version) async {
    // Tabela de Usuários
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL
      )
    ''');

    // Tabela de Perfil
    await db.execute('''
      CREATE TABLE perfil (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL UNIQUE,
        nome TEXT,
        sexo TEXT,
        idade TEXT,
        peso TEXT,
        altura TEXT,
        nivelAtividade TEXT,
        objetivo TEXT,
        restricoes TEXT,
        FOREIGN KEY (userId) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');

    // Tabela de Receitas
    await db.execute('''
      CREATE TABLE receitas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        categoria TEXT NOT NULL,
        imagem TEXT NOT NULL,
        ingredientes TEXT NOT NULL,
        modo_preparo TEXT NOT NULL
      )
    ''');

    // Popula a tabela de receitas
    Batch batch = db.batch();
    for (var receita in todasAsReceitas) {
      batch.insert('receitas', {
        'nome': receita['nome'],
        'categoria': receita['categoria'],
        'imagem': receita['imagem'],
        'ingredientes': jsonEncode(receita['ingredientes']),
        'modo_preparo': jsonEncode(receita['modo_preparo']),
      });
    }
    await batch.commit();

    // TABELA DE FAVORITOS (QUE ESTAVA FALTANDO)
    await db.execute('''
      CREATE TABLE receitas_favoritas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        receitaId INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES usuarios (id) ON DELETE CASCADE,
        FOREIGN KEY (receitaId) REFERENCES receitas (id) ON DELETE CASCADE,
        UNIQUE(userId, receitaId)
      )
    ''');
  }

  // Em lib/database_helper.dart

  // =====================================================
  // =========== CRUD RECEITAS (ADICIONAR NOVA) ==========
  // =====================================================

  Future<void> salvarReceita(Map<String, dynamic> receita) async {
    final db = await instance.database;

    // Precisamos converter as listas para JSON antes de salvar
    Map<String, dynamic> paraSalvar = {
      'nome': receita['nome'],
      'categoria': receita['categoria'],
      'imagem': receita['imagem'],
      'ingredientes': jsonEncode(receita['ingredientes']),
      'modo_preparo': jsonEncode(receita['modo_preparo']),
    };

    await db.insert('receitas', paraSalvar);
  }

  // =====================================================
  // ================== CRUD USUARIOS ====================
  // =====================================================

  Future<int> salvarUsuario(Map<String, dynamic> usuario) async {
    final db = await instance.database;
    return await db.insert('usuarios', usuario);
  }

  Future<Map<String, dynamic>?> getUsuarioLogin(
    String email,
    String senha,
  ) async {
    final db = await instance.database;
    final res = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  // =====================================================
  // =================== CRUD PERFIL =====================
  // =====================================================

  Future<int> salvarPerfil(Map<String, dynamic> perfil) async {
    final db = await instance.database;
    return await db.insert(
      'perfil',
      perfil,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getPerfil(int userId) async {
    final db = await instance.database;
    final res = await db.query(
      'perfil',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> deletarPerfil(int userId) async {
    final db = await instance.database;
    return await db.delete('perfil', where: 'userId = ?', whereArgs: [userId]);
  }

  // =====================================================
  // ================== CRUD RECEITAS ====================
  // =====================================================

  Future<List<Map<String, dynamic>>> getTodasReceitas() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('receitas');

    return List.generate(maps.length, (i) {
      return {
        'id': maps[i]['id'],
        'nome': maps[i]['nome'],
        'categoria': maps[i]['categoria'],
        'imagem': maps[i]['imagem'],
        'ingredientes': jsonDecode(maps[i]['ingredientes']),
        'modo_preparo': jsonDecode(maps[i]['modo_preparo']),
      };
    });
  }

  // =====================================================
  // =========== CRUD RECEITAS FAVORITAS =================
  // =====================================================

  // CREATE (Adicionar um favorito)
  Future<void> adicionarReceitaFavorita(int userId, int receitaId) async {
    final db = await instance.database;
    await db.insert('receitas_favoritas', {
      'userId': userId,
      'receitaId': receitaId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // DELETE (Remover um favorito)
  Future<void> removerReceitaFavorita(int userId, int receitaId) async {
    final db = await instance.database;
    await db.delete(
      'receitas_favoritas',
      where: 'userId = ? AND receitaId = ?',
      whereArgs: [userId, receitaId],
    );
  }

  // READ (Pegar todas as receitas favoritas de um usuário)
  Future<List<Map<String, dynamic>>> getReceitasFavoritas(int userId) async {
    final db = await instance.database;

    final res = await db.rawQuery(
      '''
      SELECT r.* FROM receitas r
      JOIN receitas_favoritas f ON r.id = f.receitaId
      WHERE f.userId = ?
    ''',
      [userId],
    );

    return List.generate(res.length, (i) {
      final receita = res[i];
      return {
        'id': receita['id'],
        'nome': receita['nome'],
        'categoria': receita['categoria'],
        'imagem': receita['imagem'],
        'ingredientes': jsonDecode(receita['ingredientes'] as String),
        'modo_preparo': jsonDecode(receita['modo_preparo'] as String),
      };
    });
  }
}
