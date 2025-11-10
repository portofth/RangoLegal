import 'package:flutter/material.dart';
import 'package:rango_legal_app/database_helper.dart';
import 'package:rango_legal_app/models/recipe.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RecipeFormScreen extends StatefulWidget {
  final int userId;
  final Recipe? recipe; 

  const RecipeFormScreen({super.key, required this.userId, this.recipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _preparationModeController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _restrictionsController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;
  
  String? _imagePath; 
  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.recipe!.name;
      _preparationModeController.text = widget.recipe!.preparationMode;
      _ingredientsController.text = widget.recipe!.ingredients;
      _restrictionsController.text = widget.recipe!.restrictions;
      _imagePath = widget.recipe!.imagePath;
    }
  }
  
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      Recipe newRecipe = Recipe(
        id: _isEditing ? widget.recipe!.id : null,
        name: _nameController.text,
        preparationMode: _preparationModeController.text,
        ingredients: _ingredientsController.text,
        restrictions: _restrictionsController.text,
        imagePath: _imagePath, 
        userId: widget.userId,
      );

      if (_isEditing) {
        await _dbHelper.updateRecipe(newRecipe);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receita atualizada com sucesso!')),
        );
      } else {
        await _dbHelper.insertRecipe(newRecipe);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receita cadastrada com sucesso!')),
        );
      }
      setState(() => _isLoading = false);
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Receita' : 'Nova Receita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imagePath != null && _imagePath!.isNotEmpty
                      ? Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, size: 50, color: Colors.red),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            Text('Adicionar Imagem da Receita', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da Receita', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Insira o nome da receita' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(labelText: 'Ingredientes (Separe por vírgulas ou linhas)', border: OutlineInputBorder()),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty ? 'Insira os ingredientes' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _preparationModeController,
                decoration: const InputDecoration(labelText: 'Modo de Preparo', border: OutlineInputBorder()),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty ? 'Insira o modo de preparo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _restrictionsController,
                decoration: const InputDecoration(labelText: 'Restrições (Ex: Sem glúten, Vegana)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveRecipe,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'Atualizar Receita' : 'Cadastrar Receita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}