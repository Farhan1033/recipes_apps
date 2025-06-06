import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipes_apps/config/base_url.dart';

class DeleteCategoryPage extends StatefulWidget {
  const DeleteCategoryPage({super.key});

  @override
  State<DeleteCategoryPage> createState() => _DeleteCategoryPageState();
}

class _DeleteCategoryPageState extends State<DeleteCategoryPage> {
  bool _isLoading = false;
  List<dynamic> categories = [];
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  Future<void> getCategories() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('$baseUrl/category/');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = data['category'] ?? data;
          _isLoading = false;
        });
      } else {
        _showMessage('Gagal memuat data');
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  Future<void> deleteCategory() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('$baseUrl/category/delete-category');
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': selectedCategoryId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          categories.removeWhere((item) => item['id'] == selectedCategoryId);
          selectedCategoryId = null;
          _isLoading = false;
        });
        _showMessage('Kategori berhasil dihapus');
      } else {
        _showMessage('Gagal menghapus kategori');
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  void _showMessage(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmDelete() {
    if (selectedCategoryId == null) {
      _showMessage('Pilih kategori yang ingin dihapus');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah kamu yakin ingin menghapus kategori ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Hapus'),
            onPressed: () {
              Navigator.pop(context);
              deleteCategory();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orangeLight = Colors.orange[400]!;
    final orangeDark = Colors.orange[600]!;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      appBar: AppBar(
        title: const Text('Hapus Kategori'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: orangeDark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Card(
                margin: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: categories.isEmpty
                      ? const Text('Tidak ada kategori untuk dihapus.')
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Hapus Kategori',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
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
                                  value: item['id'],
                                  child: Text(name),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() {
                                selectedCategoryId = value;
                              }),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _confirmDelete,
                                icon: const Icon(Icons.delete),
                                label: const Text('Hapus Kategori'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: orangeLight,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(fontSize: 16),
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
