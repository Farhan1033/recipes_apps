import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:recipes_apps/config/base_url.dart';

class DeleteRecipePage extends StatefulWidget {
  const DeleteRecipePage({super.key});

  @override
  State<DeleteRecipePage> createState() =>
      _DeleteRecipePageState();
}

class _DeleteRecipePageState
    extends State<DeleteRecipePage> {
  List<dynamic> recipeData = [];
  bool isLoading = true;
  String? selectedId;

  @override
  void initState() {
    super.initState();
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    final url = Uri.parse('${baseUrl}/recipes/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        recipeData = data['recipes'] ?? data;
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
        const SnackBar(content: Text('Pilih Resep dulu')),
      );
      return;
    }

    final url =
        Uri.parse('${baseUrl}/recipes/delete-recipe');
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

    final dropdownItems = recipeData.where((item) {
      final title = item['title'] ?? 'Unknown';
      if (seenTitles.contains(title)) {
        return false;
      } else {
        seenTitles.add(title);
        return true;
      }
    }).map<DropdownMenuItem<String>>((item) {
      final ingredientName = item['title'] ?? 'Unknown';
      return DropdownMenuItem<String>(
        value: item['id'],
        child: Text(ingredientName),
      );
    }).toList();

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
                    value: selectedId,
                    decoration: const InputDecoration(
                        labelText: 'Pilih Resep untuk dihapus'),
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
