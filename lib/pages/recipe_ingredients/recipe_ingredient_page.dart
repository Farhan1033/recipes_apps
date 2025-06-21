import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipes_apps/config/base_url.dart';

class AddRecipeIngredientsPage extends StatefulWidget {
  const AddRecipeIngredientsPage({super.key});

  @override
  State<AddRecipeIngredientsPage> createState() =>
      _AddRecipeIngredientsPageState();
}

class _AddRecipeIngredientsPageState extends State<AddRecipeIngredientsPage> {
  final TextEditingController _recipeIdController = TextEditingController();
  final List<_IngredientInput> _ingredients = [_IngredientInput()];
  bool _isLoading = false;
  bool _isLoadingRecipes = false;
  bool _isLoadingIngredients = false;

  // Data untuk dropdown
  List<Recipe> _recipes = [];
  Recipe? _selectedRecipe;
  List<Ingredient> _ingredients_list = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _loadIngredients();
  }

  @override
  void dispose() {
    _recipeIdController.dispose();
    for (var ingredient in _ingredients) {
      ingredient.dispose();
    }
    super.dispose();
  }

  // Load ingredients untuk dropdown
  Future<void> _loadIngredients() async {
    setState(() {
      _isLoadingIngredients = true;
    });

    final url = Uri.parse("$baseUrl/ingredient/");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse response sesuai format yang diberikan
        if (data is Map && data['data'] != null) {
          setState(() {
            _ingredients_list = (data['data'] as List)
                .map((json) => Ingredient.fromJson(json))
                .toList();
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        _showSnackbar("Gagal mengambil data bahan: $errorMessage",
            isError: true);
      }
    } catch (e) {
      _showSnackbar("Error saat mengambil data bahan: $e", isError: true);
    }

    setState(() {
      _isLoadingIngredients = false;
    });
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoadingRecipes = true;
    });

    final url = Uri.parse("$baseUrl/recipes/");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Pastikan data adalah list
        if (data is List) {
          setState(() {
            _recipes = data.map((json) => Recipe.fromJson(json)).toList();
          });
        } else if (data is Map && data['data'] != null) {
          // Jika response dibungkus dalam objek dengan key 'data'
          setState(() {
            _recipes = (data['data'] as List)
                .map((json) => Recipe.fromJson(json))
                .toList();
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        _showSnackbar("Gagal mengambil data resep: $errorMessage",
            isError: true);
      }
    } catch (e) {
      _showSnackbar("Error saat mengambil data resep: $e", isError: true);
    }

    setState(() {
      _isLoadingRecipes = false;
    });
  }

  void _addIngredientField() {
    setState(() {
      _ingredients.add(_IngredientInput());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      if (_ingredients.length > 1) {
        _ingredients[index].dispose();
        _ingredients.removeAt(index);
      }
    });
  }

  // Handler ketika recipe dipilih dari dropdown
  void _onRecipeSelected(Recipe? recipe) {
    setState(() {
      _selectedRecipe = recipe;
      if (recipe != null) {
        _recipeIdController.text = recipe.id ?? '';
      } else {
        _recipeIdController.clear();
      }
    });
  }

  Future<void> _submit() async {
    final recipeId = _recipeIdController.text.trim();

    if (recipeId.isEmpty) {
      _showSnackbar("Recipe ID harus diisi");
      return;
    }

    // Validasi tiap ingredient
    for (int i = 0; i < _ingredients.length; i++) {
      final ing = _ingredients[i];
      if (ing.selectedIngredient == null ||
          ing.quantityController.text.trim().isEmpty ||
          ing.unitController.text.trim().isEmpty) {
        _showSnackbar("Isi semua field bahan ke-${i + 1}");
        return;
      }
    }

    final List<Map<String, dynamic>> ingredientsData = _ingredients.map((ing) {
      return {
        "ingredient_id": ing.selectedIngredient!.id,
        "quantity": int.parse(ing.quantityController.text.trim()),
        "unit": ing.unitController.text.trim(),
      };
    }).toList();

    final Map<String, dynamic> requestBody = {
      "recipe_id": recipeId,
      "ingredients": ingredientsData,
    };

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse("$baseUrl/recipe-ingredient/create");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackbar("Data berhasil dikirim");

        // Clear form input with proper disposal
        _recipeIdController.clear();
        setState(() {
          // Dispose old controllers
          for (var ingredient in _ingredients) {
            ingredient.dispose();
          }
          _ingredients.clear();
          _ingredients.add(_IngredientInput());
          _selectedRecipe = null; // Reset dropdown selection
        });
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        _showSnackbar("Gagal kirim data: $errorMessage", isError: true);
      }
    } catch (e) {
      _showSnackbar("Error saat kirim data: $e", isError: true);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final orangeLight = Colors.orange[400]!;
    final orangeDark = Colors.orange[600]!;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      appBar: AppBar(
        title: const Text('Tambah Bahan ke Resep'),
        centerTitle: true,
        backgroundColor: orangeDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dropdown untuk memilih recipe
                if (_isLoadingRecipes)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  DropdownButtonFormField<Recipe>(
                    value: _selectedRecipe,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Resep',
                      prefixIcon: Icon(Icons.restaurant_menu),
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih resep yang akan ditambahkan bahan'),
                    items: _recipes.map((Recipe recipe) {
                      return DropdownMenuItem<Recipe>(
                        value: recipe,
                        child: Text(
                          recipe.title ?? 'Resep tanpa nama',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _onRecipeSelected,
                    isExpanded: true,
                  ),

                const SizedBox(height: 16),

                // TextField untuk Recipe ID (read-only karena diisi otomatis dari dropdown)
                TextField(
                  controller: _recipeIdController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Recipe ID (Otomatis terisi)',
                    prefixIcon: Icon(Icons.receipt_long),
                    border: OutlineInputBorder(),
                    fillColor: Color(0xFFF5F5F5),
                    filled: true,
                  ),
                ),

                const SizedBox(height: 24),

                // Dynamic ingredient inputs
                ..._ingredients.asMap().entries.map((entry) {
                  final index = entry.key;
                  final input = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text("Bahan ${index + 1}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (_ingredients.length > 1)
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeIngredientField(index),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Dropdown untuk memilih ingredient
                        DropdownButtonFormField<Ingredient>(
                          value: input.selectedIngredient,
                          decoration: const InputDecoration(
                            labelText: 'Pilih Bahan',
                            border: OutlineInputBorder(),
                          ),
                          hint: _isLoadingIngredients
                              ? const Text('Loading bahan...')
                              : const Text('Pilih bahan'),
                          items: _ingredients_list.map((Ingredient ingredient) {
                            return DropdownMenuItem<Ingredient>(
                              value: ingredient,
                              child: Text(
                                ingredient.name ?? 'Bahan tanpa nama',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: _isLoadingIngredients
                              ? null
                              : (Ingredient? selected) {
                                  setState(() {
                                    input.selectedIngredient = selected;
                                  });
                                },
                          isExpanded: true,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: input.quantityController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Quantity',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: input.unitController,
                                decoration: const InputDecoration(
                                  labelText: 'Unit (gram/ml/porsi)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addIngredientField,
                    icon: Icon(Icons.add, color: orangeDark),
                    label: Text("Tambah Bahan",
                        style: TextStyle(color: orangeDark)),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: const Icon(Icons.send),
                    label: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text("Kirim Data"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Class helper untuk input ingredient
class _IngredientInput {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  Ingredient? selectedIngredient;

  void dispose() {
    quantityController.dispose();
    unitController.dispose();
  }
}

// Model class untuk Ingredient (untuk dropdown)
class Ingredient {
  String? id;
  String? name;

  Ingredient({
    this.id,
    this.name,
  });

  Ingredient.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

// Model class untuk Recipe (untuk dropdown)
class Recipe {
  String? id;
  String? title;
  String? description;
  String? createdAt;

  Recipe({
    this.id,
    this.title,
    this.description,
    this.createdAt,
  });

  Recipe.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    title = json['title'];
    description = json['description'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['created_at'] = createdAt;
    return data;
  }
}

// Model class untuk recipe ingredient yang sesuai dengan API response
class RecipeIngredient {
  String? id;
  String? recipeId;
  String? ingredientId;
  String? ingredientName;
  String? quantity;
  String? unit;
  String? recipeTitle;
  String? createdAt;

  RecipeIngredient({
    this.id,
    this.recipeId,
    this.ingredientId,
    this.ingredientName,
    this.quantity,
    this.unit,
    this.recipeTitle,
    this.createdAt,
  });

  RecipeIngredient.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    recipeId = json['recipe_id'];
    ingredientId = json['ingredient_id'];
    ingredientName = json['ingredient_name'];
    quantity = json['quantity'];
    unit = json['unit'];
    recipeTitle = json['recipe_title'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['recipe_id'] = recipeId;
    data['ingredient_id'] = ingredientId;
    data['ingredient_name'] = ingredientName;
    data['quantity'] = quantity;
    data['unit'] = unit;
    data['recipe_title'] = recipeTitle;
    data['created_at'] = createdAt;
    return data;
  }
}
