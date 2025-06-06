import 'package:flutter/material.dart';
import 'package:recipes_apps/pages/recipes/add_recipe_page.dart';
import 'package:recipes_apps/pages/recipes/delete_recipe_page.dart';
import 'package:recipes_apps/pages/recipes/edit_recipe_page.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> recipeIngredients = [
      "Tambah Resep",
      "Ubah Resep",
      "Hapus Resep"
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      appBar: AppBar(
        title: const Text('Recipe Ingredients'),
        centerTitle: true,
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding: const EdgeInsets.all(10),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: recipeIngredients
                .map((item) => GestureDetector(
                      onTap: () {
                        if (item == "Tambah Resep") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddRecipePage(),
                              ));
                        } else if (item == "Ubah Resep") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditRecipePage()));
                        } else if (item == "Hapus Resep") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DeleteRecipePage(),
                              ));
                        }
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fastfood_outlined,
                              size: 50,
                              color: Colors.orange[600],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList()),
      ),
    );
  }
}
