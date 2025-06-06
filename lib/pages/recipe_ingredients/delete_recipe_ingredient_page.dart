import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:recipes_apps/config/base_url.dart';

class DeleteRecipeIngredientPage extends StatefulWidget {
  const DeleteRecipeIngredientPage({super.key});

  @override
  State<DeleteRecipeIngredientPage> createState() =>
      _DeleteRecipeIngredientPageState();
}

class _DeleteRecipeIngredientPageState
    extends State<DeleteRecipeIngredientPage> {
  List<dynamic> ingredientsData = [];
  bool isLoading = true;
  String? selectedId;

  @override
  void initState() {
    super.initState();
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    final url = Uri.parse('${baseUrl}/recipe-ingredient/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        ingredientsData = data['recipeIngredients'] ?? data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data')),
      );
    }
  }

  Future<void> deleteIngredient() async {
    if (selectedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih ingredient dulu')),
      );
      return;
    }

    final url =
        Uri.parse('${baseUrl}/recipe-ingredient/delete-recipe-ingredient');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': selectedId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menghapus data')));
      await fetchIngredients();
      setState(() {
        selectedId = null;
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gagal menghapus data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final seenTitles = <String>{};

    final dropdownItems = ingredientsData.where((item) {
      final title = item['recipe_title'] ?? 'Unknown';
      if (seenTitles.contains(title)) {
        return false;
      } else {
        seenTitles.add(title);
        return true;
      }
    }).map<DropdownMenuItem<String>>((item) {
      final ingredientName = item['recipe_title'] ?? 'Unknown';
      return DropdownMenuItem<String>(
        value: item['recipe_id'],
        child: Text(ingredientName),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hapus Recipe Ingredient'),
        backgroundColor: Colors.orange[600],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedId,
                    decoration: const InputDecoration(
                        labelText: 'Pilih Recipe Ingredient untuk dihapus'),
                    items: dropdownItems,
                    onChanged: (value) {
                      setState(() {
                        selectedId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400]),
                    onPressed: deleteIngredient,
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ),
    );
  }
}
