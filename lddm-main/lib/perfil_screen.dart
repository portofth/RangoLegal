import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Cores que definimos anteriormente para manter o padrão
const Color corAmareloPrincipal = Color(0xFFFBC02D);

class PerfilNutricionalScreen extends StatefulWidget {
  const PerfilNutricionalScreen({super.key});

  @override
  State<PerfilNutricionalScreen> createState() => _PerfilNutricionalScreenState();
}

class _PerfilNutricionalScreenState extends State<PerfilNutricionalScreen> {
  // 1. Controladores para cada campo do formulário
  final _nomeController = TextEditingController();
  final _sexoController = TextEditingController();
  final _idadeController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _nivelAtividadeController = TextEditingController();
  final _objetivoController = TextEditingController();
  final _restricoesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nomeController.text = prefs.getString('nome') ?? '';
      _sexoController.text = prefs.getString('sexo') ?? '';
      _idadeController.text = prefs.getString('idade') ?? '';
      _pesoController.text = prefs.getString('peso') ?? '';
      _alturaController.text = prefs.getString('altura') ?? '';
      _nivelAtividadeController.text = prefs.getString('nivelAtividade') ?? '';
      _objetivoController.text = prefs.getString('objetivo') ?? '';
      _restricoesController.text = prefs.getString('restricoes') ?? '';
    });
  }

  Future<void> _salvarDados() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nome', _nomeController.text);
      await prefs.setString('sexo', _sexoController.text);
      await prefs.setString('idade', _idadeController.text);
      await prefs.setString('peso', _pesoController.text);
      await prefs.setString('altura', _alturaController.text);
      await prefs.setString('nivelAtividade', _nivelAtividadeController.text);
      await prefs.setString('objetivo', _objetivoController.text);
      await prefs.setString('restricoes', _restricoesController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _nomeController.dispose();
    _sexoController.dispose();
    _idadeController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _nivelAtividadeController.dispose();
    _objetivoController.dispose();
    _restricoesController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: corAmareloPrincipal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, preencha este campo';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro do Perfil Nutricional'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Formulário de Perfil Nutricional',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTextField(controller: _nomeController, label: 'Nome', icon: Icons.person),
              const SizedBox(height: 16),
              _buildTextField(controller: _sexoController, label: 'Sexo', icon: Icons.wc),
              const SizedBox(height: 16),
              _buildTextField(controller: _idadeController, label: 'Idade', icon: Icons.cake, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(controller: _pesoController, label: 'Peso (kg)', icon: Icons.monitor_weight, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(controller: _alturaController, label: 'Altura (m)', icon: Icons.height, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(controller: _nivelAtividadeController, label: 'Nível de atividade física', icon: Icons.fitness_center),
              const SizedBox(height: 16),
              _buildTextField(controller: _objetivoController, label: 'Objetivo', icon: Icons.flag),
              const SizedBox(height: 16),
              _buildTextField(controller: _restricoesController, label: 'Restrições alimentares', icon: Icons.no_food),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _salvarDados,
                style: ElevatedButton.styleFrom(
                  backgroundColor: corAmareloPrincipal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}