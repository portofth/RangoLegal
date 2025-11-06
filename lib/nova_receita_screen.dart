// lib/nova_receita_screen.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';

const Color corAmareloPrincipal = Color(0xFFFBC02D);

class NovaReceitaScreen extends StatefulWidget {
  const NovaReceitaScreen({super.key});

  @override
  State<NovaReceitaScreen> createState() => _NovaReceitaScreenState();
}

class _NovaReceitaScreenState extends State<NovaReceitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _imagemController = TextEditingController();
  final _ingredientesController = TextEditingController();
  final _modoPreparoController = TextEditingController();

  Future<void> _salvarReceita() async {
    if (_formKey.currentState!.validate()) {
      final List<String> ingredientes = _ingredientesController.text.split(
        '\n',
      );
      final List<String> modoPreparo = _modoPreparoController.text.split('\n');

      Map<String, dynamic> novaReceita = {
        'nome': _nomeController.text,
        'categoria': _categoriaController.text,
        'imagem': _imagemController.text.isNotEmpty
            ? _imagemController.text
            : 'assets/images/placeholder.webp', // Imagem padrão
        'ingredientes': ingredientes,
        'modo_preparo': modoPreparo,
      };

      try {
        await DatabaseHelper.instance.salvarReceita(novaReceita);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nova receita salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar receita: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _imagemController.dispose();
    _ingredientesController.dispose();
    _modoPreparoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Nova Receita')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nomeController,
                label: 'Nome da Receita',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _categoriaController,
                label: 'Categoria (ex: Massas)',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _imagemController,
                label: 'Caminho da Imagem (ex: assets/images/bolo.webp)',
                isRequired: false, // Opcional
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ingredientesController,
                label: 'Ingredientes (1 por linha)',
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _modoPreparoController,
                label: 'Modo de Preparo (1 passo por linha)',
                maxLines: 8,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _salvarReceita,
                style: ElevatedButton.styleFrom(
                  backgroundColor: corAmareloPrincipal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Salvar Receita',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLines: maxLines,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Por favor, preencha este campo';
        }
        return null;
      },
    );
  }
}
