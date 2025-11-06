import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

// --- ESTAS SÃO AS IMPORTAÇÕES IMPORTANTES ---
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Importa nossos arquivos
import 'theme_provider.dart';
import 'perfil_screen.dart';
import 'recomendacao_screen.dart';
import 'configuracoes_screen.dart';
import 'login_screen.dart';
import 'database_helper.dart';

// Em lib/main.dart (no topo, com as outras importações)
import 'nova_receita_screen.dart';
import 'favoritos_screen.dart'; // Importando a nova tela de favoritos

// Cores personalizadas
const Color corAmareloClaro = Color(0xFFFFFDE7);
const Color corAmareloPrincipal = Color(0xFFFBC02D);

// =====================================================
// ============== FUNÇÃO main() CORRIGIDA ==============
// =====================================================
void main() async {
  // 1. Adicionado 'async'

  // 2. Garante que o Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Adiciona o inicializador do banco de dados para Desktop (Linux)
  // Este é o código que corrige o erro da sua imagem!
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 4. O resto da sua função main() continua igual
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}
// =====================================================

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
              seedColor: corAmareloPrincipal,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: corAmareloPrincipal,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          home: const LoginScreen(), // Tela inicial continua sendo o Login
        );
      },
    );
  }
}

// =====================================================
// ================== HomePage ========================
// =====================================================

class HomePage extends StatefulWidget {
  final int userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  final iconList = <IconData>[
    Icons.list_alt_outlined,
    Icons.person_outline,
    Icons.star_outline,
    Icons.bookmark_border, // <-- Ícone de Favoritos
    Icons.settings_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      TelaReceitas(userId: widget.userId),
      PerfilNutricionalScreen(userId: widget.userId),
      RecomendacaoScreen(userId: widget.userId),
      FavoritosScreen(userId: widget.userId), // <-- Nova Tela
      ConfiguracoesScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleFabPress() {
    // Abre a tela de cadastro de nova receita
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NovaReceitaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final navBarBackgroundColor = isDarkMode
        ? Colors.grey.shade900
        : Colors.white;
    final appBarBackgroundColor = isDarkMode
        ? Colors.grey.shade900
        : Colors.white;

    bool fabDeveAparecer = _selectedIndex != (iconList.length - 1);

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
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      floatingActionButton: fabDeveAparecer
          ? FloatingActionButton(
              onPressed: _handleFabPress,
              backgroundColor: corAmareloPrincipal,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
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
        gapLocation: fabDeveAparecer ? GapLocation.end : GapLocation.none,
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

class TelaReceitas extends StatelessWidget {
  final int userId;
  const TelaReceitas({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getTodasReceitas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar receitas: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma receita encontrada.'));
        }

        final todasAsReceitas = snapshot.data!;

        return ListView.builder(
          itemCount: todasAsReceitas.length,
          itemBuilder: (context, index) {
            final receita = todasAsReceitas[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12.0),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(receita['imagem']),
                  backgroundColor: Colors.grey[200],
                ),
                title: Text(
                  receita['nome']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(receita['categoria']!),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalheReceitaScreen(
                        receita: receita,
                        userId: userId,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// =====================================================
// =============== DetalheReceitaScreen ===============
// =====================================================

class DetalheReceitaScreen extends StatelessWidget {
  final Map<String, dynamic> receita;
  final int userId;

  const DetalheReceitaScreen({
    super.key,
    required this.receita,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> ingredientes = receita['ingredientes'];
    final List<dynamic> modoPreparo = receita['modo_preparo'];

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appBarBackgroundColor = isDarkMode
        ? Theme.of(context).scaffoldBackgroundColor
        : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        title: Text(receita['nome']),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Salvar Receita',
            onPressed: () async {
              try {
                await DatabaseHelper.instance.adicionarReceitaFavorita(
                  userId,
                  receita['id'],
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Receita salva nos seus Favoritos!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao salvar: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  receita['imagem'],
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ingredientes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              for (String ingrediente in ingredientes.cast<String>())
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: corAmareloPrincipal,
                      ),
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < modoPreparo.length; i++)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: corAmareloClaro,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  title: Text(modoPreparo[i] as String),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
