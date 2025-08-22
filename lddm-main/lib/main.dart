import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Receitinhas',
      theme: ThemeData(
        // Cor primária usada no app (AppBar, botões, etc)
        primaryColor: Colors.yellow, 
        
        // Mudar o esquema de cores principal com cor seeds
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),

        // Cor de fundo geral do Scaffold
        scaffoldBackgroundColor: Colors.grey[100],

        // Tema específico para o AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black, // cor do texto e ícones da AppBar
        ),

        // Tema para ElevatedButton para combinar com o primário
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.yellow, // Cor do texto dos botões
          ),
        ),
      ),
      home: EmojiDemoPage(),
    );
  }
}

class EmojiDemoPage extends StatefulWidget {
  const EmojiDemoPage({super.key});

  @override
  _EmojiDemoPageState createState() => _EmojiDemoPageState();
}

class _EmojiDemoPageState extends State<EmojiDemoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> myTabs = [
    Tab(text: 'Salgada 🥨'),
    Tab(text: 'Doce 🍰'),
    Tab(text: 'Receitas 📑'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildListFoodSalty() {
    return ListView(
      children: const [
        ListTile(
          leading: CircleAvatar(child: Text('🥨', style: TextStyle(fontSize: 24))),
          title: Text('Pretzel'),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('🍕', style: TextStyle(fontSize: 24))),
          title: Text('Pizza'),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('🍔', style: TextStyle(fontSize: 24))),
          title: Text('Hambúrguer'),
        ),
      ],
    );
  }

  Widget _buildListFoodSweet() {
    return ListView(
      children: const [
        ListTile(
          leading: CircleAvatar(child: Text('🍰', style: TextStyle(fontSize: 24))),
          title: Text('Bolo'),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('🍩', style: TextStyle(fontSize: 24))),
          title: Text('Donut'),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('🧁', style: TextStyle(fontSize: 24))),
          title: Text('Cupcake'),
        ),
      ],
    );
  }

  Widget _buildListSavedRecipes() {
    return ListView(
      children: const [
        ListTile(
          leading: CircleAvatar(child: Text('📑', style: TextStyle(fontSize: 24))),
          title: Text('Receita de Torta'),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('📋', style: TextStyle(fontSize: 24))),
          title: Text('Receita de Bolo'),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('⭐', style: TextStyle(fontSize: 24))),
          title: Text('Receita Favorita'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulanches'),
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListFoodSalty(),
          _buildListFoodSweet(),
          _buildListSavedRecipes(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Botão Salgada pressionado!')),
                );
              },
              child: const Text('Salgada 🥨'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Botão Doce pressionado!')),
                );
              },
              child: const Text('Doce 🍰'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Botão Receitas pressionado!')),
                );
              },
              child: const Text('Receitas 📑'),
            ),
          ],
        ),
      ),
    );
  }
}
