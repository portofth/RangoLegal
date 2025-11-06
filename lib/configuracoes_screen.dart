import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 1. IMPORTAÇÃO REMOVIDA
// import 'package:shared_preferences/shared_preferences.dart';
// 2. IMPORTAÇÃO ADICIONADA
import 'database_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme_provider.dart'; // Importa nosso gerenciador de tema
import 'login_screen.dart';

class ConfiguracoesScreen extends StatelessWidget {
  // 3. TELA AGORA RECEBE O 'userId'
  final int userId;
  const ConfiguracoesScreen({super.key, required this.userId});

  // Função para mostrar o diálogo de confirmação
  // 4. FUNÇÃO ATUALIZADA para receber o userId
  void _showResetConfirmationDialog(BuildContext context, int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Ação'),
          content: const Text(
            'Você tem certeza que deseja apagar seu perfil nutricional? Esta ação não pode ser desfeita.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
            TextButton(
              child: const Text('Apagar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // 5. Passa o userId para a função de apagar
                _resetProfile(context, userId);
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
          ],
        );
      },
    );
  }

  // Função para apagar os dados do perfil
  // 6. FUNÇÃO ATUALIZADA para usar DatabaseHelper
  void _resetProfile(BuildContext context, int userId) async {
    // Apaga o perfil do banco de dados usando o userId
    await DatabaseHelper.instance.deletarPerfil(userId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil nutricional apagado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Função para abrir URLs (Não muda)
  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Não foi possível abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurações'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Seção de Aparência (Não muda)
              _buildSectionTitle('Aparência'),
              SwitchListTile(
                title: const Text('Modo Escuro'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  themeProvider.toggleTheme(value);
                },
              ),
              const Divider(),

              // Seção de Gerenciamento de Dados
              _buildSectionTitle('Dados'),
              ListTile(
                leading: const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.red,
                ),
                title: const Text(
                  'Limpar Perfil Nutricional',
                  style: TextStyle(color: Colors.red),
                ),
                // 7. Chamada de função ATUALIZADA para passar o userId
                onTap: () => _showResetConfirmationDialog(context, userId),
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.black),
                title: const Text('Sair do Perfil'),
                onTap: () {
                  // Redireciona para a tela de login (Correto!)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
              const Divider(),

              // Seção Sobre (Não muda)
              _buildSectionTitle('Sobre'),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Avaliar o App'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Enviar Feedback'),
                onTap: () {
                  _launchURL(
                    'mailto:seuemail@exemplo.com?subject=Feedback sobre o RangoLegal',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre o RangoLegal'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'RangoLegal',
                    applicationVersion: '1.0.0 - Beta',
                    applicationLegalese:
                        '© 2025 RangoLegalLTD.\nTodos os direitos reservados.',
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'Um aplicativo para ajudar você a encontrar as melhores receitas para seus objetivos!',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget auxiliar para criar os títulos de seção (Não muda)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 8.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
    );
  }
}
