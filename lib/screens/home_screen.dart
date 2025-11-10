import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rango_legal_app/database_helper.dart';
import 'package:rango_legal_app/models/recipe.dart';
import 'package:rango_legal_app/models/profile.dart';
import 'package:rango_legal_app/screens/login_screen.dart';
import 'package:rango_legal_app/screens/recipe_form_screen.dart';
import 'package:rango_legal_app/screens/profile_form_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Recipe> _recipes = [];
  Profile? _userProfile;
  bool _profileExists = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    await _loadUserProfile();
    await _loadRecipes();
    setState(() {
      _isLoading = false;
    });
  }

  _loadUserProfile() async {
    Profile? profile = await _dbHelper.getProfileByUserId(widget.userId);
    setState(() {
      _userProfile = profile;
      _profileExists = profile != null;
    });
  }

  _loadRecipes() async {
    List<Recipe> recipes = await _dbHelper.getRecipesByUserId(widget.userId);
    setState(() {
      _recipes = recipes;
    });
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _confirmDelete(Recipe recipe) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir a receita "${recipe.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await _dbHelper.deleteRecipe(recipe.id!);
                Navigator.of(context).pop();
                _loadRecipes();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Receitas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil Nutricional',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileFormScreen(
                    userId: widget.userId,
                    isNewProfile: !_profileExists,
                  ),
                ),
              ).then((_) => _loadUserProfile());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _profileExists
              ? (_recipes.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Nenhuma receita cadastrada ainda. Use o botão "+" abaixo para adicionar sua primeira receita!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        
                        final imageWidget = recipe.imagePath != null && recipe.imagePath!.isNotEmpty
                            ? SizedBox(
                                width: 50, 
                                height: 50, 
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.file(
                                    File(recipe.imagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.red),
                                  ),
                                ),
                              )
                            : const Icon(Icons.local_dining, color: Colors.green, size: 30);

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                          elevation: 3,
                          child: ListTile(
                            leading: imageWidget,
                            title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Restrições: ${recipe.restrictions.isEmpty ? "Nenhuma" : recipe.restrictions}', maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(recipe),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeFormScreen(
                                    userId: widget.userId,
                                    recipe: recipe,
                                  ),
                                ),
                              ).then((_) => _loadRecipes());
                            },
                          ),
                        );
                      },
                    ))
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Por favor, complete seu perfil nutricional para começar a cadastrar receitas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_task),
                        label: const Text('Criar Perfil Agora'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileFormScreen(
                                userId: widget.userId,
                                isNewProfile: true,
                              ),
                            ),
                          ).then((_) => _loadUserProfile());
                        },
                      ),
                    ],
                  ),
                ),
      floatingActionButton: _profileExists
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeFormScreen(userId: widget.userId),
                  ),
                ).then((_) => _loadRecipes());
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}