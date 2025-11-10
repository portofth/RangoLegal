import 'package:flutter/material.dart';
import 'package:rango_legal_app/database_helper.dart';
import 'package:rango_legal_app/models/profile.dart';
import 'package:rango_legal_app/models/user.dart';
import 'package:rango_legal_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileFormScreen extends StatefulWidget {
  final int userId;
  final bool isNewProfile; 
  const ProfileFormScreen({super.key, required this.userId, this.isNewProfile = true});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();
  final TextEditingController _restrictionsController = TextEditingController();
  final TextEditingController _activityLevelController = TextEditingController();
  final TextEditingController _nutritionalGoalController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _sex; 

  final DatabaseHelper _dbHelper = DatabaseHelper();
  Profile? _existingProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  _loadProfileData() async {
    User? user = await _dbHelper.getUserById(widget.userId);
    _existingProfile = await _dbHelper.getProfileByUserId(widget.userId);
    
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
    }
    
    if (_existingProfile != null) {
      _firstNameController.text = _existingProfile!.firstName;
      _lastNameController.text = _existingProfile!.lastName;
      _preferencesController.text = _existingProfile!.preferences;
      _restrictionsController.text = _existingProfile!.restrictions;
      _activityLevelController.text = _existingProfile!.activityLevel;
      _nutritionalGoalController.text = _existingProfile!.nutritionalGoal;
      _weightController.text = _existingProfile!.weight.toString();
      _heightController.text = _existingProfile!.height.toString();
      _ageController.text = _existingProfile!.age.toString();
      _sex = _existingProfile!.sex;
    }

    setState(() {
      _isLoading = false;
    });
  }

  _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      Profile profile = Profile(
        id: _existingProfile?.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        preferences: _preferencesController.text,
        restrictions: _restrictionsController.text,
        activityLevel: _activityLevelController.text,
        nutritionalGoal: _nutritionalGoalController.text,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        age: int.parse(_ageController.text),
        sex: _sex!, 
        userId: widget.userId,
      );

      if (widget.isNewProfile && _existingProfile == null) {
        await _dbHelper.insertProfile(profile);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil criado com sucesso!')),
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', widget.userId); 
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userId: widget.userId)),
        );
      } else {
        await _dbHelper.updateProfile(profile);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.pop(context); 
      }
       setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewProfile && _existingProfile == null ? 'Criar Perfil Nutricional' : 'Editar Perfil Nutricional'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'Primeiro Nome', border: OutlineInputBorder()),
                        validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Sobrenome', border: OutlineInputBorder()),
                        validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _preferencesController,
                        decoration: const InputDecoration(labelText: 'Preferências Alimentares', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _restrictionsController,
                        decoration: const InputDecoration(labelText: 'Restrições Alimentares', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _activityLevelController,
                        decoration: const InputDecoration(labelText: 'Nível de Atividade', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _nutritionalGoalController,
                        decoration: const InputDecoration(labelText: 'Objetivo Nutricional', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              decoration: const InputDecoration(labelText: 'Peso (kg)', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              validator: (value) => (value == null || double.tryParse(value) == null) ? 'Peso inválido' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              decoration: const InputDecoration(labelText: 'Altura (cm)', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              validator: (value) => (value == null || double.tryParse(value) == null) ? 'Altura inválida' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                       Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              decoration: const InputDecoration(labelText: 'Idade', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              validator: (value) => (value == null || int.tryParse(value) == null) ? 'Idade inválida' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                             child: DropdownButtonFormField<String>(
                                value: _sex,
                                decoration: const InputDecoration(labelText: 'Sexo', border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                                  DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                                  DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                                ],
                                onChanged: (String? newValue) {
                                  setState(() { _sex = newValue; });
                                },
                                validator: (value) => value == null ? 'Campo obrigatório' : null,
                              ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(widget.isNewProfile && _existingProfile == null ? 'Criar Perfil' : 'Atualizar Perfil'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}