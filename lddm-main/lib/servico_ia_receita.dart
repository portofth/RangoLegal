import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meu_app/models/profile.dart';
import 'package:meu_app/database_helper.dart';
import 'package:meu_app/servico_recomendacao.dart';
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

  // 3. Tenta gerar receita com retry automático (passa userId para checagens de duplicidade)
  final receitaFormatada = await _gerarReceitaComRetry(profile, userId: userId, maxTentativas: 3);
      
      if (receitaFormatada == null) {
        throw Exception('Não foi possível gerar receita após 3 tentativas');
      }

      // 4. Salva a receita em SharedPreferences para exibição em recomendações
      print('5️⃣ Salvando receita em recomendações...');
      
      // Usa o ServicoRecomendacao para adicionar à lista de receitas IA
      final servicoRecomendacao = ServicoRecomendacao();
      await servicoRecomendacao.adicionarReceitaIA(receitaFormatada);
      
      print('   ✅ Receita salva em recomendações!');
      print('✅ Receita pronta!');
      return receitaFormatada;
    } catch (e) {
      print('❌ Erro ao gerar receita com IA: $e');
      rethrow;
    }
  }

  /// Gera receita com retry automático quando Spoonacular não encontra
  Future<Map<String, dynamic>?> _gerarReceitaComRetry(
    Profile profile, {
    required int userId,
    int maxTentativas = 3,
  }) async {
    // Prepara lista de nomes existentes (normalizados) para evitar duplicatas
    final db = DatabaseHelper();
    final servicoRecomendacao = ServicoRecomendacao();
    List<String> existingNames = [];
    try {
      final userRecipes = await db.getRecipesByUserId(userId);
      existingNames.addAll(userRecipes.map((r) => _normalize(r.name ?? '')));
    } catch (e) {
      print('⚠️ Não foi possível buscar receitas do usuário: $e');
    }
    try {
      final iaList = await servicoRecomendacao.getRecomendacoes();
      existingNames.addAll(iaList.map((r) => _normalize(r['nome'] ?? r['name'] ?? '')));
    } catch (e) {
      print('⚠️ Não foi possível buscar receitas IA existentes: $e');
    }
    // Remove duplicatas na lista local
    existingNames = existingNames.toSet().toList();
    for (int tentativa = 1; tentativa <= maxTentativas; tentativa++) {
      try {
        print('🔄 Tentativa $tentativa/$maxTentativas...');

  // 1. Gera um termo de busca usando Gemini com base no perfil e nas receitas já existentes
  print('1️⃣ Gerando termo de busca...');
  final searchTerm = await _gerarTermoBuscaComGemini(profile, existingRecipeNames: existingNames);
        print('   ✅ Termo: "$searchTerm"');

        // 2. Busca uma receita na Spoonacular usando o termo
        print('2️⃣ Buscando receita na Spoonacular...');
  final receitaSpoonacular = await _buscarReceitaSpoonacular(searchTerm, existingRecipeNames: existingNames);
        
        if (receitaSpoonacular == null) {
          print('   ⚠️ Nenhuma receita encontrada para: $searchTerm');
          if (tentativa < maxTentativas) {
            print('   🔄 Tentando termo diferente...');
            await Future.delayed(const Duration(milliseconds: 500));
            continue;
          }
          return null;
        }

        print('   ✅ Receita: ${receitaSpoonacular['title']}');

        // 3. Obtém detalhes completos da receita
        print('3️⃣ Obtendo detalhes da receita...');
        final receitaDetalhes = await _obterDetalhesReceitaSpoonacular(
          receitaSpoonacular['id'],
        );

        if (receitaDetalhes == null) {
          print('   ⚠️ Não foi possível obter detalhes');
          if (tentativa < maxTentativas) {
            print('   🔄 Tentando novamente...');
            await Future.delayed(const Duration(milliseconds: 500));
            continue;
          }
          return null;
        }

  print('   ✅ Detalhes obtidos');

        // 4. Resume e traduz a receita usando Gemini
        print('4️⃣ Traduzindo e formatando receita em português...');
        final receitaFormatada = await _resumirETraduzirReceitaComGemini(
          receitaDetalhes,
        );

        if (receitaFormatada == null) {
          print('   ⚠️ Erro ao traduzir receita');
          if (tentativa < maxTentativas) {
            print('   🔄 Tentando novamente...');
            await Future.delayed(const Duration(milliseconds: 500));
            continue;
          }
          return null;
        }

        // ✅ Sucesso! Retorna a receita
        return receitaFormatada;
      } catch (e) {
        print('   ❌ Erro na tentativa $tentativa: $e');
        if (tentativa < maxTentativas) {
          print('   🔄 Tentando novamente...');
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    return null;
  }

  /// Usa Gemini para gerar um termo de busca baseado no perfil
  Future<String> _gerarTermoBuscaComGemini(Profile profile, {List<String>? existingRecipeNames}) async {
    try {
      // Monta strings formatadas do perfil
      final restricoes = profile.restrictions.isEmpty 
          ? 'Nenhuma' 
          : profile.restrictions;
      
      final buffer = StringBuffer();
      buffer.writeln('''Você é um nutricionista. Baseado no perfil do usuário, sugira UM ÚNICO ingrediente ou tipo de prato em inglês para uma receita saudável.''');
      buffer.writeln();
      buffer.writeln('PERFIL DO USUÁRIO:');
      buffer.writeln('- Objetivo: ${profile.nutritionalGoal}');
      buffer.writeln('- Restrições alimentares: $restricoes');
      buffer.writeln('- Nível de atividade: ${profile.activityLevel}');
      buffer.writeln('- Idade: ${profile.age}');
      buffer.writeln();
      buffer.writeln('REGRAS IMPORTANTES:');
      buffer.writeln('1. Escolha receitas VARIADAS - não repita sempre "chicken", "salad" ou "soup"');
      buffer.writeln('2. Considere o objetivo nutricional:');
      buffer.writeln('   - Emagrecimento: prefira vegetais, proteínas magras, menos carboidratos');
      buffer.writeln('   - Ganho muscular: prefira proteínas, carnes, ovos, leguminosas');
      buffer.writeln('   - Manutenção: variedade equilibrada');
      buffer.writeln('3. Respeite as restrições alimentares');
      buffer.writeln('4. Escolha ingredientes ou pratos comuns que existam em bases de receitas');
      buffer.writeln('5. Retorne APENAS UM termo em inglês, sem explicações');
      buffer.writeln();
      if (existingRecipeNames != null && existingRecipeNames.isNotEmpty) {
        buffer.writeln('RECEITAS EXISTENTES (não sugira algo que produza o mesmo nome):');
        for (var n in existingRecipeNames.take(20)) {
          buffer.writeln('- ${n}');
        }
        buffer.writeln();
      }
      buffer.writeln('EXEMPLOS DE RESPOSTAS VÁLIDAS:');
      buffer.writeln('- "grilled salmon"');
      buffer.writeln('- "quinoa bowl"');
      buffer.writeln('- "lentil curry"');
      buffer.writeln('- "shrimp stir-fry"');
      buffer.writeln('- "vegetable stew"');
      buffer.writeln('- "tofu pad thai"');
      buffer.writeln('- "baked cod"');
      buffer.writeln('- "chickpea pasta"');
      buffer.writeln();
      buffer.writeln('Retorne APENAS o termo, nada mais.');

  final prompt = buffer.toString();

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
  Future<Map<String, dynamic>?> _buscarReceitaSpoonacular(String searchTerm, {List<String>? existingRecipeNames}) async {
    try {
      // Pede mais resultados para poder filtrar duplicatas localmente
      final url = Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?apiKey=$spoonacularApiKey&query=$searchTerm&number=5&language=pt',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = (data['results'] as List).cast<Map<String, dynamic>>();
        if (results.isNotEmpty) {
          // Se houver nomes existentes, compare e retorne o primeiro que não esteja na lista
          if (existingRecipeNames != null && existingRecipeNames.isNotEmpty) {
            for (var r in results) {
              final title = (r['title'] ?? r['name'] ?? '').toString();
              final norm = _normalize(title);
              if (!existingRecipeNames.contains(norm)) {
                return r;
              } else {
                print('🔁 Ignorando receita duplicada encontrada: $title');
              }
            }
            // Nenhuma não-duplicada encontrada
            return null;
          }
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
      ).timeout(const Duration(seconds: 20));

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

  // Normaliza um título para comparação simples (remove acentos, pontuação e lower case)
  String _normalize(String s) {
    String t = s.toLowerCase().trim();
    final replacements = {
      'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n'
    };
    replacements.forEach((k, v) {
      t = t.replaceAll(k, v);
    });
    // remove caracteres não alfanuméricos exceto espaço
    t = t.replaceAll(RegExp(r'[^a-z0-9 ]'), '');
    // colapsa espaços
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    return t;
  }
}

