import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main.dart'; // Para reutilizar a DetalheReceitaScreen

class FavoritosScreen extends StatefulWidget {
  final int userId; // O ID do usuário logado
  const FavoritosScreen({super.key, required this.userId});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  // O Future armazena a lista de receitas que vem do banco
  late Future<List<Map<String, dynamic>>> _favoritos;

  @override
  void initState() {
    super.initState();
    // Carrega os favoritos quando a tela é iniciada
    _loadFavoritos();
  }

  // Função separada para carregar ou RECARREGAR os favoritos
  void _loadFavoritos() {
    setState(() {
      _favoritos = DatabaseHelper.instance.getReceitasFavoritas(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Receitas Salvas'),
        // Remove a seta de "voltar" pois esta é uma tela principal
        automaticallyImplyLeading: false,
      ),
      // Adicionamos um RefreshIndicator para permitir "puxar para atualizar"
      body: RefreshIndicator(
        onRefresh: () async {
          _loadFavoritos(); // Recarrega a lista
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _favoritos,
          builder: (context, snapshot) {
            // 1. Enquanto os dados estão carregando
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Se deu algum erro
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            // 3. Se não tem dados ou a lista está vazia
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Você ainda não salvou nenhuma receita.'),
              );
            }

            // 4. Se tudo deu certo, exibe a lista!
            final receitas = snapshot.data!;
            return ListView.builder(
              itemCount: receitas.length,
              itemBuilder: (context, index) {
                final receita = receitas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(receita['imagem']),
                    ),
                    title: Text(receita['nome']),
                    subtitle: Text(receita['categoria']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalheReceitaScreen(
                            receita: receita,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                    // Botão para REMOVER dos favoritos
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Remover dos favoritos',
                      onPressed: () async {
                        // Remove a receita do banco
                        await DatabaseHelper.instance.removerReceitaFavorita(
                          widget.userId,
                          receita['id'],
                        );
                        // Mostra um feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Receita removida dos favoritos.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        // Atualiza a lista na tela
                        _loadFavoritos();
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
