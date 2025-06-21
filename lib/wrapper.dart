import 'package:flutter/material.dart';
import 'package:recipes_apps/pages/home_page.dart';
import 'package:recipes_apps/pages/recipe_ingredients/recipe_ingredient_page.dart';
import 'package:recipes_apps/pages/recipes/recipe_page.dart';
import 'package:recipes_apps/pages/settings_page.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  List bodyPage = [
    HomePage(),
    AddRecipeIngredientsPage(),
    RecipePage(),
    SettingsPage()
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavigationBar(),
      body: bodyPage[_currentIndex],
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.orange[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.post_add_outlined),
          label: 'Recipes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fastfood_outlined),
          label: 'Foods',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
