import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:recipes_apps/config/base_url.dart';

class DeleteRecipePage extends StatefulWidget {
  const DeleteRecipePage({super.key});

  @override
  State<DeleteRecipePage> createState() => _DeleteRecipePageState();
}

class _DeleteRecipePageState extends State<DeleteRecipePage> {
  List<dynamic> recipeData = [];
  bool isLoading = true;
  String? selectedId;

  @override
  void initState() {
    super.initState();
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    final url = Uri.parse('$baseUrl/recipes/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        recipeData = data['data'] ?? data;
        isLoading = false;
        // Reset selectedId jika tidak ditemukan lagi dalam data
        if (!recipeData.any((item) => item['id'] == selectedId)) {
          selectedId = null;
        }
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

  Future<void> deleteRecipe() async {
    if (selectedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih resep dulu')),
      );
      return;
    }

    final url = Uri.parse('$baseUrl/recipes/delete/$selectedId');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil menghapus data')),
      );
      setState(() {
        selectedId = null; // Kosongkan dulu sebelum refresh data
        isLoading = true;
      });
      await fetchIngredients();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropdownItems = recipeData
        .map<DropdownMenuItem<String>>((item) {
          final recipeTitle = item['title'] ?? 'Tanpa Judul';
          return DropdownMenuItem<String>(
            value: item['id'],
            child: Text(recipeTitle),
          );
        })
        .toSet()
        .toList(); // pastikan tidak ada duplikat

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hapus Resep'),
        backgroundColor: Colors.orange[600],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: recipeData.any((item) => item['id'] == selectedId)
                        ? selectedId
                        : null,
                    decoration: const InputDecoration(
                        labelText: 'Pilih Resep untuk dihapus'),
                    hint: const Text('Pilih resep'),
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
                    onPressed: deleteRecipe,
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ),
    );
  }
}
