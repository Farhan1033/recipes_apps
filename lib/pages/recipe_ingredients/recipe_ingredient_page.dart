import 'package:flutter/material.dart';
import 'package:recipes_apps/pages/recipe_ingredients/add_recipe_ingredient_page.dart';
import 'package:recipes_apps/pages/recipe_ingredients/delete_recipe_ingredient_page.dart';
import 'package:recipes_apps/pages/recipe_ingredients/edit_recipe_ingredient_page.dart';

class RecipeIngredientPage extends StatelessWidget {
  const RecipeIngredientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> recipeIngredients = [
      "Add Recipe Ingredient",
      "Edit Recipe Ingredient",
      "Delete Recipe Ingredient"
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
                        if (item == "Add Recipe Ingredient") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddRecipeIngredientsPage(),
                              ));
                        } else if (item == "Edit Recipe Ingredient") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EditRecipeIngredientPage(),
                              ));
                        } else if (item == "Delete Recipe Ingredient") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DeleteRecipeIngredientPage(),
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
                              Icons.post_add_outlined,
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
