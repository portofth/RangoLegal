import 'package:shared_preferences/shared_preferences.dart';
import 'dados_receitas.dart'; // Importa nossa lista de receitas

class ServicoRecomendacao {
  // Função principal que retorna a lista de receitas recomendadas
  Future<List<Map<String, dynamic>>> getRecomendacoes() async {
    // 1. Carrega o perfil do usuário
    final prefs = await SharedPreferences.getInstance();
    final objetivo = prefs.getString('objetivo')?.toLowerCase() ?? '';
    final restricoes = prefs.getString('restricoes')?.toLowerCase() ?? '';

    List<Map<String, dynamic>> receitasRecomendadas = [];

    // 2. Itera sobre todas as receitas disponíveis
    for (var receita in todasAsReceitas) {
      bool isApropriada = true;
      int pontuacao = 0;

      final ingredientes = (receita['ingredientes'] as List<String>).join(' ').toLowerCase();

      // --- LÓGICA DE FILTRO (RESTRIÇÕES) ---
      // Se tiver alguma restrição, verifica se a receita é válida
      if (restricoes.contains('vegetariano') && (ingredientes.contains('frango') || ingredientes.contains('carne'))) {
        isApropriada = false;
      }
      if (restricoes.contains('lactose') && (ingredientes.contains('queijo') || ingredientes.contains('leite'))) {
        isApropriada = false;
      }
      if (restricoes.contains('glúten') && ingredientes.contains('trigo')) {
        isApropriada = false;
      }

      // --- LÓGICA DE PONTUAÇÃO (OBJETIVO) ---
      // Se a receita passou pelo filtro de restrições, damos pontos a ela
      if (isApropriada) {
        if (objetivo.contains('massa muscular')) {
          if (ingredientes.contains('frango') || ingredientes.contains('ovo')) pontuacao += 10;
          if (ingredientes.contains('lentilha')) pontuacao += 5;
        }
        if (objetivo.contains('perda de peso')) {
          if (ingredientes.contains('salada') || ingredientes.contains('legumes')) pontuacao += 10;
          if (ingredientes.contains('frango')) pontuacao += 5;
          if (ingredientes.contains('açúcar') || ingredientes.contains('farinha')) pontuacao -= 10;
        }
        
        // Adiciona a pontuação na receita e a coloca na lista de recomendadas
        receita['pontuacao'] = pontuacao;
        receitasRecomendadas.add(receita);
      }
    }

    // 3. Ordena a lista: as receitas com maior pontuação vêm primeiro
    receitasRecomendadas.sort((a, b) => b['pontuacao'].compareTo(a['pontuacao']));

    return receitasRecomendadas;
  }
}