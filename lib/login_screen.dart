import 'package:flutter/material.dart';
import 'main.dart'; // Para navegar para HomePage
import 'database_helper.dart';

const Color corAmareloPrincipal = Color(0xFFFBC02D);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Em lib/login_screen.dart (dentro de _LoginScreenState)

  void _login() async {
    // 1. Adiciona 'async'
    if (_formKey.currentState!.validate()) {
      // 2. Tenta buscar o usuário no banco
      final usuarioLogado = await DatabaseHelper.instance.getUsuarioLogin(
        _emailController.text,
        _passwordController.text,
      );

      // 3. Verifica se o usuário foi encontrado
      if (usuarioLogado != null) {
        // SUCESSO! Pega o ID do usuário
        final userId = usuarioLogado['id'] as int;

        // 4. Navega para HomePage e PASSA O ID DO USUÁRIO
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userId: userId)),
        );
      } else {
        // ERRO! Usuário ou senha inválidos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email ou senha inválidos."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ADICIONE A FUNÇÃO QUE FALTAVA AQUI (ex: linha 66)
  void _abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (v) => v == null || !v.contains("@")
                          ? "Digite um email válido"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "Senha"),
                      obscureText: true,
                      validator: (v) => v == null || v.length < 6
                          ? "Senha mínima de 6 caracteres"
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corAmareloPrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Entrar",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _abrirCadastro,
                      child: const Text(
                        "Não tem uma conta? Cadastre-se",
                        style: TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// ================== CadastroScreen ==================
// =====================================================

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _cadastrar() async {
    // <-- Adicione 'async'
    if (_formKey.currentState!.validate()) {
      // 1. Cria o map (dicionário) com os dados do usuário
      Map<String, dynamic> novoUsuario = {
        'nome': _nomeController.text,
        'email': _emailController.text,
        'senha': _passwordController.text,
      };

      try {
        // 2. Chama o DatabaseHelper para salvar
        await DatabaseHelper.instance.salvarUsuario(novoUsuario);

        // 3. Volta para o login
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cadastro realizado! Faça login agora."),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Trata o erro (ex: email já existe por causa do 'UNIQUE')
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao cadastrar: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Cadastro"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Cadastro",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(labelText: "Nome"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Digite seu nome" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (v) => v == null || !v.contains("@")
                          ? "Digite um email válido"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "Senha"),
                      obscureText: true,
                      validator: (v) => v == null || v.length < 6
                          ? "Senha mínima de 6 caracteres"
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _cadastrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corAmareloPrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cadastrar",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
