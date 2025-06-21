import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipes_apps/config/base_url.dart';
import 'package:recipes_apps/pages/recipe_detail_page.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String steps;
  final String imageUrl;
  final String categoryId;
  final int cookingTime;
  final int portions;
  final String createdAt;
  final String categoryName;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.imageUrl,
    required this.categoryId,
    required this.cookingTime,
    required this.portions,
    required this.createdAt,
    required this.categoryName,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      steps: json['steps'] ?? '',
      imageUrl: json['image_url'] ?? '',
      categoryId: json['category_id'] ?? '',
      cookingTime: json['cooking_time'] ?? 0,
      portions: json['portion'] ?? 0,
      createdAt: json['created_at'] ?? '',
      categoryName: json['category'] ?? '',
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Recipe> recipes = [];
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    loadRecipes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadRecipes() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        Uri.parse('$baseUrl/recipes/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> recipeList = data['data'] ?? [];

        setState(() {
          recipes = recipeList.map((json) => Recipe.fromJson(json)).toList();
          isLoading = false;
        });

        _animationController.forward();
      } else {
        setState(() {
          errorMessage =
              'Gagal memuat data resep. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.orange[600],
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Resep Nusantara',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.orange[400]!,
                      Colors.orange[600]!,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Resep Populer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Temukan kelezatan kuliner Nusantara',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: isLoading
                ? SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orange[600]!),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Memuat resep...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : errorMessage != null
                    ? SliverToBoxAdapter(
                        child: Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 50,
                                  color: Colors.red[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: loadRecipes,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange[600],
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : recipes.isEmpty
                        ? SliverToBoxAdapter(
                            child: Container(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Belum ada resep tersedia',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final recipe = recipes[index];
                                return FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 15,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16)),
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: 200,
                                                width: double.infinity,
                                                child: Image.network(
                                                  recipe.imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[300],
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.restaurant,
                                                          size: 50,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Positioned(
                                                top: 12,
                                                left: 12,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange[600],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    recipe.categoryName,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 12,
                                                right: 12,
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Icon(
                                                    Icons.favorite_border,
                                                    color: Colors.orange[600],
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                recipe.title,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                recipe.description,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                  height: 1.4,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Icon(Icons.schedule,
                                                      size: 16,
                                                      color: Colors.grey[600]),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${recipe.cookingTime} menit',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  SizedBox(width: 16),
                                                  Icon(Icons.people,
                                                      size: 16,
                                                      color: Colors.grey[600]),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${recipe.portions} porsi',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              RecipeDetailPage(
                                                            recipeId: recipe.id,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.orange[600],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Text(
                                                        'Lihat Resep',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: recipes.length,
                            ),
                          ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loadRecipes,
        backgroundColor: Colors.orange[600],
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
