import 'package:flutter/material.dart';
import 'package:recipes_apps/pages/categories/add_category_page.dart';
import 'package:recipes_apps/pages/categories/delete_category_page.dart';
import 'package:recipes_apps/pages/ingredients/add_ingredient_page.dart';
import 'package:recipes_apps/pages/ingredients/delete_ingredient_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> settingItems = [
      'Add Category',
      'Add Ingredient',
      'Delete Category',
      'Delete Ingredient'
    ];

    final List<IconData> settingIcons = [
      Icons.category,
      Icons.fastfood,
      Icons.delete,
      Icons.delete_forever
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.orange[600],
      ),
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(settingIcons[index], color: Colors.orange[600]),
              title: settingItems.map((item) => Text(item)).toList()[index],
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                if (index == 0) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCategoryPage(),
                      ));
                } else if (index == 1) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddIngredientPage(),
                      ));
                } else if (index == 2) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeleteCategoryPage(),
                      ));
                } else if (index == 3) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeleteIngredientPage(),
                      ));
                }
              },
            ),
          );
        },
      ),
    );
  }
}
