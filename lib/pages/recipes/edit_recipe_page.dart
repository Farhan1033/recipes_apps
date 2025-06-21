import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipes_apps/config/base_url.dart';

class EditRecipePage extends StatefulWidget {
  const EditRecipePage({super.key});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController categoryIdController = TextEditingController();
  final TextEditingController cookingTimeController = TextEditingController();
  final TextEditingController portionsController = TextEditingController();

  bool isLoading = false;
  List<dynamic> categories = [];
  List<dynamic> recipes = [];
  String? selectedCategoryName;
  String? selectedRecipeId;

  @override
  void initState() {
    super.initState();
    fetchCategoryData();
    fetchRecipeData();
  }

  Future<void> fetchRecipeData() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/recipes/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] != null) {
          setState(() {
            recipes = List.from(data['data']);
          });
        } else {
          throw Exception('Format data resep tidak valid');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> fetchRecipeIdData() async {
    if (selectedRecipeId == null) return;

    setState(() => isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/recipes/$selectedRecipeId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is! Map || data['data'] == null) {
          throw Exception('Format data resep tidak valid');
        }
        final datas = data['data'];
        setState(() {
          titleController.text = datas['title']?.toString() ?? '';
          descriptionController.text = datas['description']?.toString() ?? '';
          stepsController.text = datas['steps']?.toString() ?? '';
          imageUrlController.text = datas['image_url']?.toString() ?? '';
          categoryIdController.text = datas['category_id']?.toString() ?? '';
          cookingTimeController.text = datas['cooking_time']?.toString() ?? '0';
          portionsController.text = datas['portion']?.toString() ?? '0';

          // Set selected category name based on category_id
          if (datas['category_id'] != null) {
            final category = categories.firstWhere(
              (c) => c['id'].toString() == datas['category_id'].toString(),
              orElse: () => null,
            );
            if (category != null) {
              selectedCategoryName = category['name']?.toString();
            }
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> fetchCategoryData() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/category/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] != null) {
          setState(() {
            categories = List.from(data['data']);
          });
        } else {
          throw Exception('Format data kategori tidak valid');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> updateRecipe() async {
    if (selectedRecipeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih resep terlebih dahulu')),
      );
      return;
    }

    try {
      int cookingTime = 0;
      int portion = 0;

      // Parse cooking time dengan validasi
      String cookingTimeText = cookingTimeController.text.trim();
      if (cookingTimeText.isNotEmpty) {
        cookingTime = int.tryParse(cookingTimeText) ?? 0;
      }

      // Parse portions dengan validasi
      String portionsText = portionsController.text.trim();
      if (portionsText.isNotEmpty) {
        portion = int.tryParse(portionsText) ?? 0;
      }

      final url = Uri.parse('$baseUrl/recipes/update/$selectedRecipeId');
      final requestData = {
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "steps": stepsController.text.trim(),
        "image_url": imageUrlController.text.trim(),
        "category_id": categoryIdController.text.trim(),
        "cooking_time": cookingTime,
        "portion": portion,
      };

      final body = jsonEncode(requestData);

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil diperbarui!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: buildInputDecoration(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orangeColor = Colors.orange.shade400;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: orangeColor,
        title: const Text('Edit Resep'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      value: selectedRecipeId,
                      decoration: buildInputDecoration('Pilih Resep'),
                      items: recipes.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['id']?.toString(),
                          child: Text(item['title']?.toString() ?? 'No Title'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRecipeId = value;
                          if (value != null) {
                            fetchRecipeIdData();
                          }
                        });
                      },
                    ),
                  ),
                  buildTextField('Judul', titleController),
                  buildTextField('Deskripsi', descriptionController),
                  buildTextField('Langkah-langkah', stepsController,
                      maxLines: 4),
                  buildTextField('URL Gambar', imageUrlController),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategoryName,
                      decoration: buildInputDecoration('Pilih Kategori'),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['name']?.toString(),
                          child: Text(
                              category['name']?.toString() ?? 'No Category'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryName = value;
                          final selected = categories.firstWhere(
                            (c) => c['name']?.toString() == value,
                            orElse: () => null,
                          );
                          if (selected != null) {
                            categoryIdController.text =
                                selected['id']?.toString() ?? '';
                          }
                        });
                      },
                    ),
                  ),
                  buildTextField('Waktu Masak (menit)', cookingTimeController,
                      keyboardType: TextInputType.number),
                  buildTextField('Jumlah Porsi', portionsController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: updateRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
