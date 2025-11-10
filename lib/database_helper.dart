import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:rango_legal_app/models/user.dart';
import 'package:rango_legal_app/models/profile.dart';
import 'package:rango_legal_app/models/recipe.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'rango_legal.db');

    return await openDatabase(
      path,
      version: 2, // VERSÃO 2: Adição da coluna imagePath em Recipes
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Adicionar onUpgrade
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE User (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        preferences TEXT,
        restrictions TEXT,
        activityLevel TEXT,
        nutritionalGoal TEXT,
        weight REAL,
        height REAL,
        age INTEGER,
        sex TEXT,
        userId INTEGER UNIQUE,
        FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE Recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        preparationMode TEXT,
        ingredients TEXT,
        restrictions TEXT,
        imagePath TEXT, 
        userId INTEGER,
        FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE
      )
    ''');
  }
  
  // LÓGICA DE MIGRAÇÃO
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adiciona a coluna imagePath
      await db.execute("ALTER TABLE Recipes ADD COLUMN imagePath TEXT;");
    }
  }


  // --- Operações CRUD (User) ---
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('User', user.toMap());
  }

  Future<User?> getUser(String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'User',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'User',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  
  Future<User?> getUserById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'User',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // --- Operações CRUD (Profile) ---
  Future<int> insertProfile(Profile profile) async {
    Database db = await database;
    return await db.insert('Profile', profile.toMap());
  }

  Future<Profile?> getProfileByUserId(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'Profile',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return Profile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProfile(Profile profile) async {
    Database db = await database;
    return await db.update(
      'Profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // --- Operações CRUD (Recipes) ---
  Future<int> insertRecipe(Recipe recipe) async {
    Database db = await database;
    return await db.insert('Recipes', recipe.toMap());
  }

  Future<List<Recipe>> getRecipesByUserId(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'Recipes',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }

  Future<int> updateRecipe(Recipe recipe) async {
    Database db = await database;
    return await db.update(
      'Recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    Database db = await database;
    return await db.delete(
      'Recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}