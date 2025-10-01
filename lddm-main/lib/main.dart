import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

// Importa todos os nossos arquivos de tela e lógica
import 'theme_provider.dart';
import 'perfil_screen.dart';
import 'recomendacao_screen.dart';
import 'dados_receitas.dart';
import 'configuracoes_screen.dart';
import 'login_screen.dart'; // Tela de login

// Cores personalizadas
const Color corAmareloClaro = Color(0xFFFFFDE7);
const Color corAmareloPrincipal = Color(0xFFFBC02D);

void main() {
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
          // 🔹 Tela inicial é o Login
          home: const LoginScreen(),
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
    PerfilNutricionalScreen(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ação: Adicionar nova receita.')),
        );
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ação: Criar novo perfil nutricional.')),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ação: Filtrar recomendações.')),
        );
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

class TelaReceitas extends StatelessWidget {
  const TelaReceitas({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todasAsReceitas.length,
      itemBuilder: (context, index) {
        final receita = todasAsReceitas[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  builder: (context) => DetalheReceitaScreen(receita: receita),
                ),
              );
            },
          ),
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
  const DetalheReceitaScreen({super.key, required this.receita});
  @override
  Widget build(BuildContext context) {
    final List<String> ingredientes = receita['ingredientes'];
    final List<String> modoPreparo = receita['modo_preparo'];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appBarBackgroundColor =
        isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        title: Text(receita['nome']),
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
