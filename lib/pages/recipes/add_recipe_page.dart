import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
        if (data is Map && data['data'] != null) {
          setState(() {
            categories = List.from(data['data']);
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

  Future<void> uploadImageToFirebase() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    final path = result.files.single.path!;
    final file = File(path);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('recipes/$fileName-${result.files.single.name}');
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        imageUrlController.text = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar berhasil diupload')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload gambar: $e')),
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

      final url = Uri.parse('${baseUrl}/recipes/create');

      final body = jsonEncode({
        "title": titleController.text,
        "description": descriptionController.text,
        "steps": stepsController.text,
        "image_url": imageUrlController.text,
        "category_id": selectedCategoryId,
        "cooking_time": int.tryParse(cookingTimeController.text) ?? 0,
        "portion": int.tryParse(portionsController.text) ?? 0,
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

                  /// 📸 Upload Gambar Section
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: imageUrlController,
                          decoration:
                              buildInputDecoration('URL Gambar (hasil upload)'),
                          readOnly: true,
                          validator: (value) =>
                              value!.isEmpty ? 'Wajib upload gambar' : null,
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: uploadImageToFirebase,
                        icon: Icon(Icons.upload),
                        label: Text("Upload"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[300],
                        ),
                      )
                    ],
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
