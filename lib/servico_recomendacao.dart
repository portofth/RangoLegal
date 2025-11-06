// 1. Importações REMOVIDAS
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dados_receitas.dart';

// 2. Importação ADICIONADA
import 'database_helper.dart';

class ServicoRecomendacao {
  // 3. Função principal agora recebe o userId
  Future<List<Map<String, dynamic>>> getRecomendacoes(int userId) async {
    // 4. Carrega o perfil e as receitas do BANCO DE DADOS
    final perfil = await DatabaseHelper.instance.getPerfil(userId);
    final todasAsReceitas = await DatabaseHelper.instance.getTodasReceitas();

    // Se não houver perfil, retorna uma lista vazia
    if (perfil == null) {
      return [];
    }

    final objetivo = perfil['objetivo']?.toLowerCase() ?? '';
    final restricoes = perfil['restricoes']?.toLowerCase() ?? '';

    List<Map<String, dynamic>> receitasRecomendadas = [];

    // 5. Itera sobre todas as receitas do BANCO
    for (var receita in todasAsReceitas) {
      bool isApropriada = true;
      int pontuacao = 0;

      // Os ingredientes agora são uma Lista (como definido no banco)
      final ingredientes = (receita['ingredientes'] as List<dynamic>)
          .join(' ')
          .toLowerCase();

      // --- LÓGICA DE FILTRO (RESTRIÇÕES) ---
      // Esta lógica é a mesma que você já tinha
      if (restricoes.contains('vegetariano') &&
          (ingredientes.contains('frango') || ingredientes.contains('carne'))) {
        isApropriada = false;
      }
      if (restricoes.contains('lactose') &&
          (ingredientes.contains('queijo') || ingredientes.contains('leite'))) {
        isApropriada = false;
      }
      if (restricoes.contains('glúten') && ingredientes.contains('trigo')) {
        isApropriada = false;
      }

      // --- LÓGICA DE PONTUAÇÃO (OBJETIVO) ---
      // Esta lógica é a mesma que você já tinha
      if (isApropriada) {
        if (objetivo.contains('massa muscular')) {
          if (ingredientes.contains('frango') || ingredientes.contains('ovo'))
            pontuacao += 10;
          if (ingredientes.contains('lentilha')) pontuacao += 5;
        }
        if (objetivo.contains('perda de peso')) {
          if (ingredientes.contains('salada') ||
              ingredientes.contains('legumes'))
            pontuacao += 10;
          if (ingredientes.contains('frango')) pontuacao += 5;
          if (ingredientes.contains('açúcar') ||
              ingredientes.contains('farinha'))
            pontuacao -= 10;
        }

        receita['pontuacao'] = pontuacao;
        receitasRecomendadas.add(receita);
      }
    }

    // 6. Ordena a lista
    receitasRecomendadas.sort(
      (a, b) => b['pontuacao'].compareTo(a['pontuacao']),
    );

    return receitasRecomendadas;
  }
}
