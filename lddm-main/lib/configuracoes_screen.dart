import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme_provider.dart'; // Importa nosso gerenciador de tema

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  // Função para mostrar o diálogo de confirmação
  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Ação'),
          content: const Text('Você tem certeza que deseja apagar seu perfil nutricional? Esta ação não pode ser desfeita.'),
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
                _resetProfile(context);
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
          ],
        );
      },
    );
  }

  // Função para apagar os dados do perfil
  void _resetProfile(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    // Lista de chaves do perfil para remover
    final profileKeys = [
      'nome', 'sexo', 'idade', 'peso', 'altura', 
      'nivelAtividade', 'objetivo', 'restricoes'
    ];
    for (String key in profileKeys) {
      await prefs.remove(key);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil nutricional apagado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Função para abrir URLs
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
    // Usamos um Consumer para acessar e modificar o estado do tema
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
              // Seção de Aparência
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
                leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                title: const Text('Limpar Perfil Nutricional', style: TextStyle(color: Colors.red)),
                onTap: () => _showResetConfirmationDialog(context),
              ),
              const Divider(),

              // Seção Sobre
              _buildSectionTitle('Sobre'),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Avaliar o App'),
                onTap: () {
                  // TODO: Substitua pela URL da sua loja de apps
                  // _launchURL('https://play.google.com/store/apps/details?id=com.example.app');
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Enviar Feedback'),
                onTap: () {
                  // TODO: Substitua pelo seu e-mail
                  _launchURL('mailto:seuemail@exemplo.com?subject=Feedback sobre o RangoLegal');
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
                    applicationLegalese: '© 2025 Seu Nome Aqui.\nTodos os direitos reservados.',
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Text('Um aplicativo para ajudar você a encontrar as melhores receitas para seus objetivos!'),
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

  // Widget auxiliar para criar os títulos de seção
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16.0, right: 16.0),
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