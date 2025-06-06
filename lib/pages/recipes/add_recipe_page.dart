import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:recipes_apps/config/base_url.dart';

class AddRecipePage extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  List<dynamic> categories = [];
  String? selectedCategoryId;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final stepsController = TextEditingController();
  final imageUrlController = TextEditingController();
  final cookingTimeController = TextEditingController();
  final portionsController = TextEditingController();

  bool isLoading = false;

  Future<void> getCategories() async {
    final url = Uri.parse('${baseUrl}/category/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data['category'] != null) {
          setState(() {
            categories = List.from(data['category']);
          });
        } else {
          throw Exception('Format data kategori tidak valid');
        }
      } else {
        throw Exception('Gagal memuat kategori');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mengambil kategori: $e')),
      );
    }
  }

  Future<void> submitRecipe() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori harus dipilih')),
        );
        return;
      }

      setState(() => isLoading = true);

      final url = Uri.parse('${baseUrl}/recipes/create-recipe');

      final body = jsonEncode({
        "title": titleController.text,
        "description": descriptionController.text,
        "steps": stepsController.text,
        "image_url": imageUrlController.text,
        "category_id": selectedCategoryId,
        "cooking_time": int.tryParse(cookingTimeController.text) ?? 0,
        "portions": int.tryParse(portionsController.text) ?? 0,
      });

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Resep berhasil ditambahkan')),
          );
          Navigator.pop(context);
        } else {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'] ?? 'Gagal menambahkan resep')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange[600]!),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange[400]!),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    stepsController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: Text('Tambah Resep'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: buildInputDecoration('Judul Resep'),
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: buildInputDecoration('Deskripsi'),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: stepsController,
                    decoration: buildInputDecoration('Langkah-langkah'),
                    maxLines: 5,
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: imageUrlController,
                    decoration: buildInputDecoration('URL Gambar'),
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    items: categories.map<DropdownMenuItem<String>>((item) {
                      final name = item['name'] ?? 'Unnamed';
                      return DropdownMenuItem<String>(
                        value: item['id'].toString(),
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() {
                      selectedCategoryId = value;
                    }),
                    validator: (value) =>
                        value == null ? 'Kategori wajib dipilih' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: cookingTimeController,
                    decoration: buildInputDecoration('Waktu Memasak (menit)'),
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: portionsController,
                    decoration: buildInputDecoration('Porsi'),
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 24),
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange[600],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: submitRecipe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[400],
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Simpan Resep',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
