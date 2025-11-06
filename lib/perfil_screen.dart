import 'package:flutter/material.dart';
// 1. IMPORTAÇÃO REMOVIDA
// import 'package:shared_preferences/shared_preferences.dart';
// 2. IMPORTAÇÃO ADICIONADA
import 'database_helper.dart';

// Cores que definimos anteriormente para manter o padrão
const Color corAmareloPrincipal = Color(0xFFFBC02D);

class PerfilNutricionalScreen extends StatefulWidget {
  // 3. TELA AGORA RECEBE O 'userId'
  final int userId;
  const PerfilNutricionalScreen({super.key, required this.userId});

  @override
  State<PerfilNutricionalScreen> createState() =>
      _PerfilNutricionalScreenState();
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

  // 4. FUNÇÃO _carregarDados ATUALIZADA (usa DatabaseHelper)
  Future<void> _carregarDados() async {
    // Busca o perfil no banco usando o ID do usuário (widget.userId)
    final perfil = await DatabaseHelper.instance.getPerfil(widget.userId);

    // Se encontramos um perfil, preenchemos os campos
    if (perfil != null) {
      setState(() {
        _nomeController.text = perfil['nome'] ?? '';
        _sexoController.text = perfil['sexo'] ?? '';
        _idadeController.text = perfil['idade'] ?? '';
        _pesoController.text = perfil['peso'] ?? '';
        _alturaController.text = perfil['altura'] ?? '';
        _nivelAtividadeController.text = perfil['nivelAtividade'] ?? '';
        _objetivoController.text = perfil['objetivo'] ?? '';
        _restricoesController.text = perfil['restricoes'] ?? '';
      });
    }
  }

  // 5. FUNÇÃO _salvarDados ATUALIZADA (usa DatabaseHelper)
  Future<void> _salvarDados() async {
    if (_formKey.currentState!.validate()) {
      // 1. Cria o Map de dados para o banco
      Map<String, dynamic> perfilData = {
        'userId': widget.userId, // <-- VINCULA O PERFIL AO USUÁRIO LOGADO
        'nome': _nomeController.text,
        'sexo': _sexoController.text,
        'idade': _idadeController.text,
        'peso': _pesoController.text,
        'altura': _alturaController.text,
        'nivelAtividade': _nivelAtividadeController.text,
        'objetivo': _objetivoController.text,
        'restricoes': _restricoesController.text,
      };

      // 2. Salva no banco de dados
      // A função 'salvarPerfil' já faz o INSERT ou UPDATE automático
      await DatabaseHelper.instance.salvarPerfil(perfilData);

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

  // 6. O RESTO DO CÓDIGO (Interface Gráfica) NÃO MUDA
  // O Widget _buildTextField continua igual
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

  // O Widget build continua igual
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
              _buildTextField(
                controller: _nomeController,
                label: 'Nome',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _sexoController,
                label: 'Sexo',
                icon: Icons.wc,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _idadeController,
                label: 'Idade',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _pesoController,
                label: 'Peso (kg)',
                icon: Icons.monitor_weight,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _alturaController,
                label: 'Altura (m)',
                icon: Icons.height,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nivelAtividadeController,
                label: 'Nível de atividade física',
                icon: Icons.fitness_center,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _objetivoController,
                label: 'Objetivo',
                icon: Icons.flag,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _restricoesController,
                label: 'Restrições alimentares',
                icon: Icons.no_food,
              ),
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
