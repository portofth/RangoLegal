import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RangoLegal',
      theme: ThemeData(
        primaryColor: Colors.yellow,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.yellow,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Splash Screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.restaurant_menu, size: 80, color: Colors.yellow),
            SizedBox(height: 20),
            Text('Bem-vindo ao RangoLegal!', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

// Login/Cadastro
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Cadastro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tela de Login/Cadastro', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigation()),
                );
              },
              child: const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Barra de navegação principal
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const RecipeListScreen(),
    const ProfileScreen(),
    const RecommendationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RangoLegal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecipeFormScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Receitas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Recomendação'),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

// Receita
class Recipe {
  final String nome;
  final String ingredientes;
  final String modoPreparo;
  final String categoria;
  final String imagemUrl;

  Recipe({
    required this.nome,
    required this.ingredientes,
    required this.modoPreparo,
    required this.categoria,
    required this.imagemUrl,
  });
}

// Lista de receitas adicionadas
// TODO: Substituir por banco de dados futuramente
List<Recipe> receitasAdicionadas = [];

// Tela de Lista de Receitas 
class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.cake),
          title: const Text('Bolo de Chocolate'),
          subtitle: const Text('Sobremesa'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecipeDetailScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.local_pizza),
          title: const Text('Pizza Margherita'),
          subtitle: const Text('Massas'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecipeDetailScreen()),
            );
          },
        ),
        // Receitas adicionadas pelo usuário
        ...receitasAdicionadas.map((receita) => ListTile(
          leading: receita.imagemUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    receita.imagemUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.fastfood),
          title: Text(receita.nome),
          subtitle: Text(receita.categoria),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreenCustom(recipe: receita),
              ),
            );
          },
        )),
      ],
    );
  }
}

// Tela de Detalhes da Receita 
class RecipeDetailScreenCustom extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreenCustom({required this.recipe, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.nome)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (recipe.imagemUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  recipe.imagemUrl,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(recipe.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Ingredientes:', style: const TextStyle(fontSize: 18)),
            Text(recipe.ingredientes),
            const SizedBox(height: 10),
            Text('Modo de Preparo:', style: const TextStyle(fontSize: 18)),
            Text(recipe.modoPreparo),
            const SizedBox(height: 20),
            Text('Categoria: ${recipe.categoria}'),
          ],
        ),
      ),
    );
  }
}

// Tela de Detalhes da Receita
class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Receita')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Nome da Receita', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Ingredientes:', style: TextStyle(fontSize: 18)),
            Text('- Ingrediente 1\n- Ingrediente 2'),
            SizedBox(height: 10),
            Text('Modo de Preparo:', style: TextStyle(fontSize: 18)),
            Text('1. Passo um\n2. Passo dois'),
            SizedBox(height: 20),
            Text('Categoria: Sobremesa'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecipeFormScreen()),
          );
        },
      ),
    );
  }
}

// Tela de Cadastro do Perfil Nutricional 
class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});
  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  // TODO: Substituir por banco de dados futuramente
  final _nomeController = TextEditingController(text: 'João Silva');
  final _sexoController = TextEditingController(text: 'Masculino');
  final _idadeController = TextEditingController(text: '32');
  final _pesoController = TextEditingController(text: '78');
  final _alturaController = TextEditingController(text: '1,80');
  final _atividadeController = TextEditingController(text: 'Moderado (3x/semana)');
  final _objetivoController = TextEditingController(text: 'Ganho de massa muscular');
  final _restricoesController = TextEditingController(text: 'Nenhuma');
  final _preferenciasController = TextEditingController(text: 'Carnes magras, legumes, frutas');
  final _historicoController = TextEditingController(text: 'Sem doenças crônicas');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro do Perfil Nutricional')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Formulário de Perfil Nutricional', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _sexoController,
              decoration: const InputDecoration(labelText: 'Sexo'),
            ),
            TextField(
              controller: _idadeController,
              decoration: const InputDecoration(labelText: 'Idade'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _pesoController,
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _alturaController,
              decoration: const InputDecoration(labelText: 'Altura (m)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _atividadeController,
              decoration: const InputDecoration(labelText: 'Nível de atividade física'),
            ),
            TextField(
              controller: _objetivoController,
              decoration: const InputDecoration(labelText: 'Objetivo'),
            ),
            TextField(
              controller: _restricoesController,
              decoration: const InputDecoration(labelText: 'Restrições alimentares'),
            ),
            TextField(
              controller: _preferenciasController,
              decoration: const InputDecoration(labelText: 'Preferências alimentares'),
            ),
            TextField(
              controller: _historicoController,
              decoration: const InputDecoration(labelText: 'Histórico de saúde'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil salvo!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela CRUD de Receita 
class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key});
  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  // TODO: Substituir por banco de dados futuramente
  final _nomeController = TextEditingController();
  final _ingredientesController = TextEditingController();
  final _modoPreparoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _imagemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar/Editar Receita')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Formulário de Receita', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome da Receita'),
            ),
            TextField(
              controller: _ingredientesController,
              decoration: const InputDecoration(labelText: 'Ingredientes (separe por vírgula)'),
              maxLines: 2,
            ),
            TextField(
              controller: _modoPreparoController,
              decoration: const InputDecoration(labelText: 'Modo de Preparo'),
              maxLines: 3,
            ),
            TextField(
              controller: _categoriaController,
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            TextField(
              controller: _imagemController,
              decoration: const InputDecoration(labelText: 'URL da Imagem'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final receita = Recipe(
                  nome: _nomeController.text,
                  ingredientes: _ingredientesController.text,
                  modoPreparo: _modoPreparoController.text,
                  categoria: _categoriaController.text,
                  imagemUrl: _imagemController.text,
                );
                receitasAdicionadas.add(receita);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receita adicionada!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Salvar Receita'),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de Perfil Nutricional
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Perfil Nutricional', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileFormScreen()),
              );
            },
            child: const Text('Editar Perfil'),
          ),
        ],
      ),
    );
  }
}

// Tela de Recomendação da IA
class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});
  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
 
  // TODO: Substituir por dados vindos do banco de dados ou IA futuramente
  String recipeName = 'Salada Colorida';
  String recipeImage =
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80';
  List<String> ingredients = [
    'Alface',
    'Tomate',
    'Cenoura',
    'Pepino',
    'Azeite',
    'Sal'
  ];
  String reason =
      'A IA escolheu esta receita por ser leve, nutritiva e adequada ao seu perfil nutricional.';

  void _requestNewRecipe() {
   
    // TODO: Substituir por lógica real/banco de dados
    setState(() {
      recipeName = 'Omelete de Legumes';
      recipeImage =
          'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=400&q=80';
      ingredients = ['Ovos', 'Cenoura', 'Abobrinha', 'Cebola', 'Sal', 'Azeite'];
      reason =
          'A IA selecionou esta receita por ser rica em proteínas e fácil de preparar.';
    });
  }

  void _saveRecipe() {
    // TODO: Salvar receita no banco de dados futuramente
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receita salva no livro de receitas!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  recipeImage,
                  height: 160,
                  width: 160,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(recipeName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Ingredientes:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ingredients
                      .map((ing) => Text('- $ing',
                          style: const TextStyle(fontSize: 16)))
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
              Text('Motivo da escolha pela IA:',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(reason, style: const TextStyle(fontSize: 15)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _requestNewRecipe,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Solicitar nova receita'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveRecipe,
                    icon: const Icon(Icons.bookmark),
                    label: const Text('Salvar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
