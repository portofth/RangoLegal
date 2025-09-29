import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Cores personalizadas definidas em um só lugar
const Color corAmareloClaro = Color(0xFFFFFDE7);
const Color corAmareloPrincipal = Color(0xFFFBC02D);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RangoLegal',
      theme: ThemeData(
        // 2. Tema moderno usando ColorScheme com a nova cor
        colorScheme: ColorScheme.fromSeed(seedColor: corAmareloPrincipal),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    TelaReceitas(),
    PlaceholderScreen(texto: 'Tela de Perfil'),
    PlaceholderScreen(texto: 'Tela de Recomendações'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'RangoLegal',
          style: GoogleFonts.pacifico(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: corAmareloPrincipal, // <-- COR ATUALIZADA
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: corAmareloPrincipal, // <-- COR ATUALIZADA
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Receitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Recomendação',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: corAmareloPrincipal, // <-- COR ATUALIZADA
        onTap: _onItemTapped,
      ),
    );
  }
}

class TelaReceitas extends StatelessWidget {
  const TelaReceitas({super.key});

  final List<Map<String, dynamic>> receitas = const [
    {
      "nome": "Bolo de Chocolate",
      "categoria": "Sobremesa",
      "imagem": "assets/images/bolo.webp",
      "ingredientes": [
        "3 ovos", "1 xícara de açúcar", "2 xícaras de farinha de trigo",
        "1 xícara de chocolate em pó", "1/2 xícara de óleo", "1 xícara de água quente",
        "1 colher de sopa de fermento em pó"
      ],
      "modo_preparo": [
        "Bata os ovos e o açúcar até obter um creme fofo.",
        "Adicione o óleo e o chocolate em pó, misturando bem.",
        "Intercale a adição da farinha de trigo e da água quente, mexendo até a massa ficar homogênea.",
        "Por último, adicione o fermento em pó e misture delicadamente.",
        "Despeje a massa em uma forma untada e enfarinhada.",
        "Asse em forno preaquecido a 180°C por aproximadamente 40 minutos."
      ]
    },
    {
      "nome": "Pizza Margherita",
      "categoria": "Massas",
      "imagem": "assets/images/pizza.webp",
      "ingredientes": [
        "1 disco de massa de pizza", "1/2 xícara de molho de tomate", "150g de queijo muçarela ralado",
        "Tomates cereja cortados ao meio", "Folhas de manjericão fresco a gosto", "Azeite de oliva a gosto"
      ],
      "modo_preparo": [
        "Pré-aqueça o forno a 220°C.", "Espalhe o molho de tomate sobre o disco de pizza.",
        "Cubra com o queijo muçarela.", "Distribua os tomates cereja sobre o queijo.",
        "Leve ao forno por 10-15 minutos, ou até a massa dourar e o queijo derreter.",
        "Retire do forno, regue com azeite e decore com as folhas de manjericão."
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: receitas.length,
      itemBuilder: (context, index) {
        final receita = receitas[index];
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

class DetalheReceitaScreen extends StatelessWidget {
  final Map<String, dynamic> receita;

  const DetalheReceitaScreen({super.key, required this.receita});

  @override
  Widget build(BuildContext context) {
    final List<String> ingredientes = receita['ingredientes'];
    final List<String> modoPreparo = receita['modo_preparo'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              for (String ingrediente in ingredientes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 18, color: corAmareloPrincipal), // <-- COR ATUALIZADA
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < modoPreparo.length; i++)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: corAmareloClaro, // <-- COR ATUALIZADA
                    child: Text('${i + 1}', style: const TextStyle(color: Colors.black87)),
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