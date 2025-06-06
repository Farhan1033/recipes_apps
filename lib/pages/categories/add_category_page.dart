import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:recipes_apps/config/base_url.dart';

class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addCategory() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackbar('Nama kategori tidak boleh kosong', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('${baseUrl}/category/create-category');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': _nameController.text.trim()}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showSnackbar(
            '✅ ${data["message"]}');
        _nameController.clear();
      } else {
        _showSnackbar('❌ Gagal: ${data["message"] ?? "Terjadi kesalahan"}',
            isError: true);
      }
    } catch (e) {
      _showSnackbar('❌ Error: $e', isError: true);
    }

    setState(() => _isLoading = false);
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orangeLight = Colors.orange[400]!;
    final orangeDark = Colors.orange[600]!;

    return Scaffold(
      backgroundColor: Color(0xFFFDF6F0),
      appBar: AppBar(
        title: Text('Tambah Kategori'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: orangeDark,
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Masukkan Nama Kategori',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _addCategory,
                    icon: Icon(Icons.add),
                    label: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Tambah Kategori'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 16),
                      elevation: 4,
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
