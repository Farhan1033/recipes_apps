import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipes_apps/config/base_url.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  TextEditingController nameCategory = TextEditingController();
  String isError = '';
  List<dynamic> data = [];
  String? selectCategory;
  String? selectId;

  Future<void> handleCreateCategory() async {
    final url = Uri.parse('$baseUrl/category/create-category');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"name": nameCategory.text}),
      );

      if (response.statusCode == 200) {
        print('berhasil post data');
        setState(() {
          isError = 'Berhasil post data';
        });
      } else {
        setState(() {
          isError = 'Gagal post data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error : $e');
    }
  }

  Future<void> fetchCategory() async {
    final url = Uri.parse('$baseUrl/category/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('Berhasil mengambil data');
        final result = json.decode(response.body);
        setState(() {
          data = result['category'];
        });
      } else {
        print('Gagal mengambil data');
      }
    } catch (e) {
      print('Error : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: selectCategory,
                hint: const Text('Pilih Kategori'),
                items: data.map<DropdownMenuItem<String>>((item) {
                  return DropdownMenuItem<String>(
                      value: item['name'], child: Text(item['name']));
                }).toList(),
                onChanged: (value) {
                  final selected = data.firstWhere((item) => item['name'] == value);
                  setState(() {
                    selectCategory = value;
                    selectId = selected['id'];
                  });
                },
              ),
              const SizedBox(
                height: 16,
              ),
              Text('ID Kategor $selectId'),
              const SizedBox(
                height: 16,
              ),
              TextField(
                controller: nameCategory,
                decoration: const InputDecoration(
                  hintText: 'Masukkan Kategori Makanan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    handleCreateCategory();
                  });
                },
                child: const Text('Kirim Data'),
              ),
              const SizedBox(height: 16),
              Text(
                isError,
                style: TextStyle(
                    color: isError.contains('Berhasil')
                        ? Colors.green
                        : Colors.red),
              )
            ],
          ),
        ),
      ),
    );
  }
}
