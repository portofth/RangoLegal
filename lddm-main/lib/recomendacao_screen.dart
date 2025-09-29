import 'package:flutter/material.dart';
import 'servico_recomendacao.dart'; // Importa nossa lógica
import 'main.dart'; // Para acessar a tela de detalhes

class RecomendacaoScreen extends StatefulWidget {
  const RecomendacaoScreen({super.key});

  @override
  State<RecomendacaoScreen> createState() => _RecomendacaoScreenState();
}

class _RecomendacaoScreenState extends State<RecomendacaoScreen> {
  late Future<List<Map<String, dynamic>>> _recomendacoes;

  @override
  void initState() {
    super.initState();
    // Inicia o processo de obter as recomendações
    _recomendacoes = ServicoRecomendacao().getRecomendacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendações para Você'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      // FutureBuilder é perfeito para lidar com dados que demoram a chegar
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recomendacoes,
        builder: (context, snapshot) {
          // 1. Enquanto os dados estão carregando, mostra um indicador de progresso
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Se deu algum erro
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar recomendações: ${snapshot.error}'));
          }
          // 3. Se os dados chegaram com sucesso, mas a lista está vazia
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma recomendação encontrada para seu perfil.'));
          }

          // 4. Se tudo deu certo, mostra a lista
          final receitas = snapshot.data!;
          return ListView.builder(
            itemCount: receitas.length,
            itemBuilder: (context, index) {
              final receita = receitas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12.0),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(receita['imagem']),
                  ),
                  title: Text(receita['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(receita['categoria']),
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
        },
      ),
    );
  }
}