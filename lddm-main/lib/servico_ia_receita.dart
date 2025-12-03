import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meu_app/models/profile.dart';
import 'package:meu_app/database_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ServicoIAReceita {
  
  

// chave do Gemini
   String geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  // chave do Spoonacular
    String spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY'] ?? '';




  /// Lista os modelos disponíveis
  Future<void> listarModelos() async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models?key=$geminiApiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📋 Modelos disponíveis:');
        for (var model in data['models']) {
          print('  - ${model['name']}');
        }
      } else {
        print('Erro ao listar modelos: ${response.statusCode}');
        print('Body: ${response.body}');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  /// Gera uma receita usando IA baseada no perfil nutricional do usuário
  Future<Map<String, dynamic>?> gerarReceitaComIA() async {
    try {
      // 1. Carrega o perfil do usuário
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;
      
      if (userId == 0) {
        throw Exception('Usuário não autenticado');
      }

      // 2. Busca o perfil do banco de dados
      final db = DatabaseHelper();
      final profile = await db.getProfileByUserId(userId);
      
      if (profile == null) {
        throw Exception('Perfil nutricional não encontrado. Por favor, crie um perfil primeiro.');
      }

      print('⏳ Iniciando geração de receita com IA...');

      // 3. Gera um termo de busca usando Gemini com base no perfil
      print('1️⃣ Gerando termo de busca...');
      final searchTerm = await _gerarTermoBuscaComGemini(profile);
      print('   ✅ Termo: "$searchTerm"');

      // 4. Busca uma receita na Spoonacular usando o termo
      print('2️⃣ Buscando receita na Spoonacular...');
      final receitaSpoonacular = await _buscarReceitaSpoonacular(searchTerm);
      
      if (receitaSpoonacular == null) {
        throw Exception('Nenhuma receita encontrada para: $searchTerm');
      }

      print('   ✅ Receita: ${receitaSpoonacular['title']}');

      // 5. Obtém detalhes completos da receita
      print('3️⃣ Obtendo detalhes da receita...');
      final receitaDetalhes = await _obterDetalhesReceitaSpoonacular(
        receitaSpoonacular['id'],
      );

      if (receitaDetalhes == null) {
        throw Exception('Não foi possível obter os detalhes da receita');
      }

      print('   ✅ Detalhes obtidos');

      // 6. Resume e traduz a receita usando Gemini
      print('4️⃣ Traduzindo e formatando receita em português...');
      final receitaFormatada = await _resumirETraduzirReceitaComGemini(
        receitaDetalhes,
      );

      // 7. Salva a receita em SharedPreferences para exibição em recomendações
      if (receitaFormatada != null) {
        print('5️⃣ Salvando receita em recomendações...');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'ultima_receita_ia',
          jsonEncode(receitaFormatada),
        );
        print('   ✅ Receita salva em recomendações!');
      }

      print('✅ Receita pronta!');
      return receitaFormatada;
    } catch (e) {
      print('❌ Erro ao gerar receita com IA: $e');
      rethrow;
    }
  }

  /// Usa Gemini para gerar um termo de busca baseado no perfil
  Future<String> _gerarTermoBuscaComGemini(Profile profile) async {
    try {
      // Monta strings formatadas do perfil
      final restricoes = profile.restrictions.isEmpty 
          ? 'Nenhuma' 
          : profile.restrictions;
      
      final prompt = '''
Você é um nutricionista. Baseado no perfil do usuário, sugira UM ÚNICO ingrediente ou tipo de prato em inglês para uma receita saudável.

PERFIL DO USUÁRIO:
- Objetivo: ${profile.nutritionalGoal}
- Restrições alimentares: $restricoes
- Nível de atividade: ${profile.activityLevel}
- Idade: ${profile.age}

REGRAS IMPORTANTES:
1. Escolha receitas VARIADAS - não repita sempre "chicken", "salad" ou "soup"
2. Considere o objetivo nutricional:
   - Emagrecimento: prefira vegetais, proteínas magras, menos carboidratos
   - Ganho muscular: prefira proteínas, carnes, ovos, leguminosas
   - Manutenção: variedade equilibrada
3. Respeite as restrições alimentares
4. Escolha ingredientes ou pratos comuns que existam em bases de receitas
5. Retorne APENAS UM termo em inglês, sem explicações

EXEMPLOS DE RESPOSTAS VÁLIDAS:
- "grilled salmon"
- "quinoa bowl"
- "lentil curry"
- "shrimp stir-fry"
- "vegetable stew"
- "tofu pad thai"
- "baked cod"
- "chickpea pasta"

Retorne APENAS o termo, nada mais.
''';

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$geminiApiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final searchTerm = data['candidates'][0]['content']['parts'][0]['text']
            .toString()
            .trim()
            .replaceAll('"', '')
            .replaceAll("'", '')
            .replaceAll('`', '')
            .split('\n')[0];
        return searchTerm.isNotEmpty ? searchTerm : 'chicken';
      } else {
        print('❌ Status: ${response.statusCode}');
        print('❌ Body: ${response.body}');
        throw Exception('Erro ao chamar Gemini: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao gerar termo de busca: $e');
      // Fallback: retorna um termo padrão
      return 'chicken';
    }
  }

  /// Busca uma receita na Spoonacular usando um termo
  Future<Map<String, dynamic>?> _buscarReceitaSpoonacular(String searchTerm) async {
    try {
      final url = Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?apiKey=$spoonacularApiKey&query=$searchTerm&number=1&language=pt',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        
        if (results.isNotEmpty) {
          return results.first;
        }
      } else {
        throw Exception('Erro ao buscar na Spoonacular: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao buscar receita: $e');
    }
    return null;
  }

  /// Obtém detalhes completos de uma receita da Spoonacular
  Future<Map<String, dynamic>?> _obterDetalhesReceitaSpoonacular(
    int recipeId,
  ) async {
    try {
      final url = Uri.parse(
        'https://api.spoonacular.com/recipes/$recipeId/information?apiKey=$spoonacularApiKey&includeNutrition=false',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao obter detalhes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao obter detalhes da receita: $e');
    }
    return null;
  }

  /// Usa Gemini para resumir e traduzir a receita para português
  Future<Map<String, dynamic>?> _resumirETraduzirReceitaComGemini(
    Map<String, dynamic> receita,
  ) async {
    try {
      // Monta os ingredientes e modo de preparo do JSON da Spoonacular
      final ingredientes = (receita['extendedIngredients'] as List)
          .map((i) => '${i['original']}')
          .join(', ');

      final modoPreparo = receita['instructions'] ?? 'Ver instruções no site original';

      final prompt = '''
Traduzir para português e formatar como JSON APENAS. Sem explicações.

TÍTULO: ${receita['title']}
INGREDIENTES: $ingredientes
MODO DE PREPARO: $modoPreparo

Retorne JSON (sem markdown, sem blocos de código):
{
  "nome": "Nome em português",
  "categoria": "Categoria",
  "ingredientes": ["ingrediente 1", "ingrediente 2"],
  "modo_preparo": ["passo 1", "passo 2"],
  "restricoes": ""
}
''';

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$geminiApiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText = data['candidates'][0]['content']['parts'][0]['text']
            .toString()
            .trim();

        // Remove markdown se existir
        String jsonText = responseText;
        if (jsonText.contains('```json')) {
          jsonText = jsonText.replaceAll('```json', '').replaceAll('```', '');
        }
        if (jsonText.contains('```')) {
          jsonText = jsonText.replaceAll('```', '');
        }

        final receitaFormatada = jsonDecode(jsonText);

        // A imagem será adicionada APÓS a tradução, em Base64
        return receitaFormatada;
      } else {
        print('❌ Status: ${response.statusCode}');
        print('❌ Body: ${response.body}');
        throw Exception('Erro ao chamar Gemini: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao resumir e traduzir: $e');
    }
    return null;
  }
}

