import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:recipes_apps/config/base_url.dart';

class EditRecipeIngredientPage extends StatefulWidget {
  const EditRecipeIngredientPage({super.key});

  @override
  State<EditRecipeIngredientPage> createState() =>
      _EditRecipeIngredientPageState();
}

class _EditRecipeIngredientPageState extends State<EditRecipeIngredientPage> {
  List<dynamic> ingredientsData = [];
  bool isLoading = true;
  String? selectedId;
  double? quantity;
  String? unit;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();

  List<String> units = ['gram', 'ml', 'butir', 'buah', 'porsi'];

  @override
  void initState() {
    super.initState();
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    final url = Uri.parse('$baseUrl/recipe-ingredient/');
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

  void onSelectIngredient(dynamic ingredient) {
    setState(() {
      selectedId = ingredient['id'] as String;
      final q = ingredient['quantity'];
      if (q is int) {
        quantity = q.toDouble();
      } else if (q is double) {
        quantity = q;
      } else if (q is String) {
        quantity = double.tryParse(q) ?? 0.0;
      } else {
        quantity = 0.0;
      }
      unit = ingredient['unit'] as String?;
      _quantityController.text = quantity?.toString() ?? '';
    });
  }

  Future<void> submitEdit() async {
    if (_formKey.currentState!.validate() && selectedId != null) {
      final url = Uri.parse('$baseUrl/recipe-ingredient/$selectedId');
      final body = json.encode({
        'quantity': double.parse(_quantityController.text),
        'unit': unit,
      });

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Berhasil update data')));
          await fetchIngredients();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Gagal update data')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe Ingredient'),
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
                    decoration:
                        const InputDecoration(labelText: 'Pilih Ingredient'),
                    items:
                        ingredientsData.map<DropdownMenuItem<String>>((item) {
                      final ingredientName = item['ingredient_name'] ??
                          item['ingredient']?['name'] ??
                          'Unnamed';
                      return DropdownMenuItem<String>(
                        value: item['id'] as String,
                        child: Text(
                            '$ingredientName (Qty: ${item['quantity']} ${item['unit']})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      final selected =
                          ingredientsData.firstWhere((e) => e['id'] == value);
                      onSelectIngredient(selected);
                    },
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _quantityController,
                          decoration:
                              const InputDecoration(labelText: 'Quantity'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Quantity harus diisi';
                            if (double.tryParse(value) == null)
                              return 'Quantity harus angka';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: unit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: units
                              .map((u) =>
                                  DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              unit = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[400]),
                          onPressed: submitEdit,
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
