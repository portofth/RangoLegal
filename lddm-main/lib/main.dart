import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'dart:io';
import 'dart:convert' show base64Decode;

// Importa todos os nossos arquivos de tela e lógica
import 'theme_provider.dart';
import 'perfil_screen.dart';
import 'perfil_list_screen.dart';
import 'recomendacao_screen.dart';
import 'configuracoes_screen.dart';
import 'splash_screen.dart'; // Tela inicial
import 'package:meu_app/database_helper.dart';
import 'package:meu_app/models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'recipe_form.dart';

// Cores personalizadas
const Color corAmareloClaro = Color(0xFFFFFDE7);
const Color corAmareloPrincipal = Color(0xFFFBC02D);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initializeHive();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'RangoLegal',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: corAmareloPrincipal, brightness: Brightness.light),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: corAmareloPrincipal, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          // 🔹 Tela inicial é a Splash Screen
          home: const SplashScreen(),
        );
      },
    );
  }
}

// =====================================================
// ================== HomePage ========================
// =====================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    TelaReceitas(),
    PerfilListScreen(),
    RecomendacaoScreen(),
    ConfiguracoesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleFabPress() {
    switch (_selectedIndex) {
      case 0:
        // Abrir formulário de nova receita
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RecipeForm()),
        );
        break;
      case 1:
        // Abrir formulário de novo perfil nutricional
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PerfilNutricionalScreen()),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ação: Recomendações.')),
        );
        break;
      case 3:
        // Sem FAB em configurações
        break;
    }
  }

  final iconList = <IconData>[
    Icons.list_alt_outlined,
    Icons.person_outline,
    Icons.star_outline,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final navBarBackgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final appBarBackgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: appBarBackgroundColor,
        title: Text(
          'RangoLegal',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: corAmareloPrincipal,
          ),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex == 3
          ? null
          : FloatingActionButton(
              onPressed: _handleFabPress,
              backgroundColor: corAmareloPrincipal,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.black),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          return Icon(
            iconList[index],
            size: 24,
            color: isActive
                ? corAmareloPrincipal
                : (isDarkMode ? Colors.white70 : Colors.grey.shade600),
          );
        },
        activeIndex: _selectedIndex,
        gapLocation: _selectedIndex == 3 ? GapLocation.none : GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: _onItemTapped,
        backgroundColor: navBarBackgroundColor,
      ),
    );
  }
}

// =====================================================
// ================== TelaReceitas ====================
// =====================================================

class TelaReceitas extends StatefulWidget {
  const TelaReceitas({super.key});

  @override
  State<TelaReceitas> createState() => _TelaReceitasState();
}

class _TelaReceitasState extends State<TelaReceitas> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    // Tenta obter userId para filtrar receitas do usuário; se não houver, carrega todas
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    List<Recipe> recs;
    if (userId > 0) {
      recs = await _db.getRecipesByUserId(userId);
    } else {
      // Se não cadastrado, tenta carregar todas as receitas (não implementado no DB)
      recs = [];
    }
    setState(() {
      _recipes = recs;
    });
  }

  void _openRecipeForm([Recipe? recipe]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecipeForm(recipe: recipe)),
    );
    if (result == true) {
      await _loadRecipes();
    }
  }

  Widget _buildRecipeImage(Recipe receita) {
    // Se houver uma imagem, tenta carregá-la
    if (receita.imagePath != null && receita.imagePath!.isNotEmpty) {
      // Se for asset (começa com 'assets/')
      if (receita.imagePath!.contains('assets/')) {
        return CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          backgroundImage: AssetImage(receita.imagePath!),
          child: ClipOval(
            child: Image.asset(
              receita.imagePath!,
              fit: BoxFit.cover,
              width: 56,
              height: 56,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackAvatar(receita);
              },
            ),
          ),
        );
      }
      // Se for Base64 (web)
      else if (receita.imagePath!.startsWith('data:image/')) {
        return CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          backgroundImage: MemoryImage(
            base64Decode(receita.imagePath!.split(',').last),
          ),
          onBackgroundImageError: (exception, stackTrace) {
            // Fallback para avatar com letra
          },
        );
      }
      // Se for caminho de arquivo (Android/iOS)
      else {
        return CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          backgroundImage: FileImage(File(receita.imagePath!)),
          onBackgroundImageError: (exception, stackTrace) {
            // Fallback
          },
          child: _buildFallbackAvatar(receita),
        );
      }
    }
    // Fallback padrão
    return _buildFallbackAvatar(receita);
  }

  Widget _buildFallbackAvatar(Recipe receita) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.grey[200],
      child: Text(
        receita.name.isNotEmpty ? receita.name[0].toUpperCase() : '?',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _recipes.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Nenhuma receita encontrada.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _openRecipeForm(),
                    child: const Text('Adicionar primeira receita'),
                  )
                ],
              ),
            ),
          )
        : ListView.builder(
            itemCount: _recipes.length,
            itemBuilder: (context, index) {
              final receita = _recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12.0),
                  leading: _buildRecipeImage(receita),
                  title: Text(
                    receita.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(receita.restrictions),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalheReceitaScreen(receita: receita),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openRecipeForm(receita),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Excluir receita'),
                              content: const Text('Deseja realmente excluir esta receita?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _db.deleteRecipe(receita.id ?? 0);
                            await _loadRecipes();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

// =====================================================
// =============== DetalheReceitaScreen ===============
// =====================================================

class DetalheReceitaScreen extends StatefulWidget {
  final Recipe receita;
  const DetalheReceitaScreen({super.key, required this.receita});

  @override
  State<DetalheReceitaScreen> createState() => _DetalheReceitaScreenState();
}

class _DetalheReceitaScreenState extends State<DetalheReceitaScreen> {
  @override
  Widget build(BuildContext context) {
    final receita = widget.receita;
    final List<String> ingredientes = receita.ingredients.split('\n');
    final List<String> modoPreparo = receita.preparationMode.split('\n');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appBarBackgroundColor =
        isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white;

    Widget imageWidget;
    if (receita.imagePath != null && receita.imagePath!.isNotEmpty) {
      // Asset images
      if (receita.imagePath!.contains('assets/')) {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.asset(
            receita.imagePath!,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[200],
                child: const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
              );
            },
          ),
        );
      }
      // Base64 images (web)
      else if (receita.imagePath!.startsWith('data:image/')) {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.memory(
            base64Decode(receita.imagePath!.split(',').last),
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[200],
                child: const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
              );
            },
          ),
        );
      }
      // File images (Android/iOS)
      else {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.file(
            File(receita.imagePath!),
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[200],
                child: const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
              );
            },
          ),
        );
      }
    } else {
      imageWidget = Container(
        width: double.infinity,
        height: 250,
        color: Colors.grey[200],
        child: const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        title: Text(receita.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              if (receita.id == null) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receita não pode ser excluída.')));
                return;
              }
              // ignore: use_build_context_synchronously
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Excluir receita'),
                  content: const Text('Deseja realmente excluir esta receita?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Excluir')),
                  ],
                ),
              );
              if (confirmed == true) {
                final db = DatabaseHelper();
                await db.deleteRecipe(receita.id!);
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                Navigator.pop(context, true);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageWidget,
              const SizedBox(height: 24),
              Text(
                'Ingredientes',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              for (String ingrediente in ingredientes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 18, color: corAmareloPrincipal),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ingrediente)),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                'Modo de Preparo',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < modoPreparo.length; i++)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: corAmareloClaro,
                    child: Text('${i + 1}',
                        style: const TextStyle(color: Colors.black87)),
                  ),
                  title: Text(modoPreparo[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// ================== PlaceholderScreen ================
// =====================================================

class PlaceholderScreen extends StatelessWidget {
  final String texto;
  const PlaceholderScreen({super.key, required this.texto});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        texto,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
