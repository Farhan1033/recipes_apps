import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipes_apps/config/base_url.dart';

class Ingredient {
  final String id;
  final String name;
  final int quantity;
  final String unit;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
    );
  }
}

class RecipeDetail {
  final String id;
  final String recipeId;
  final String title;
  final String category;
  final int cookingTime;
  final int portion;
  final String description;
  final String steps;
  final String imageUrl;
  final String createdAt;
  final List<Ingredient> ingredients;

  RecipeDetail({
    required this.id,
    required this.recipeId,
    required this.title,
    required this.category,
    required this.cookingTime,
    required this.portion,
    required this.description,
    required this.steps,
    required this.imageUrl,
    required this.createdAt,
    required this.ingredients,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    var ingredientsList = json['ingredients'] as List? ?? [];
    List<Ingredient> ingredients = ingredientsList
        .map((ingredient) => Ingredient.fromJson(ingredient))
        .toList();

    return RecipeDetail(
      id: json['id'] ?? '',
      recipeId: json['recipe_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      cookingTime: json['cooking_time'] ?? 0,
      portion: json['portion'] ?? 0,
      description: json['description'] ?? '',
      steps: json['steps'] ?? '',
      imageUrl: json['image_url'] ?? '',
      createdAt: json['created_at'] ?? '',
      ingredients: ingredients,
    );
  }
}

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;

  const RecipeDetailPage({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage>
    with TickerProviderStateMixin {
  RecipeDetail? recipe;
  bool isLoading = true;
  String? errorMessage;
  bool isFavorite = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    loadRecipeDetail();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadRecipeDetail() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        Uri.parse('$baseUrl/recipe-ingredient/${widget.recipeId}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        setState(() {
          recipe = RecipeDetail.fromJson(data);
          isLoading = false;
        });

        _animationController.forward();
      } else {
        setState(() {
          errorMessage =
              'Gagal memuat detail resep. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
        print(e);
        print(widget.recipeId);
      });
    }
  }

  List<String> getStepsList() {
    if (recipe == null) return [];
    return recipe!.steps
        .split('\n')
        .where((step) => step.trim().isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat detail resep...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: loadRecipeDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 300,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.orange[600],
                      elevation: 0,
                      leading: Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      actions: [
                        Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey[800],
                            ),
                            onPressed: () {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                            },
                          ),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          child: Image.network(
                            recipe?.imageUrl ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 80,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title and Category
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              recipe?.title ?? '',
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                                height: 1.2,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.orange[100],
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                recipe?.category ?? '',
                                                style: TextStyle(
                                                  color: Colors.orange[800],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 20),

                                  // Quick Info
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(Icons.schedule,
                                                color: Colors.orange[600],
                                                size: 24),
                                            SizedBox(height: 4),
                                            Text(
                                              '${recipe?.cookingTime} menit',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            Text(
                                              'Waktu Masak',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 40,
                                          width: 1,
                                          color: Colors.grey[300],
                                        ),
                                        Column(
                                          children: [
                                            Icon(Icons.people,
                                                color: Colors.orange[600],
                                                size: 24),
                                            SizedBox(height: 4),
                                            Text(
                                              '${recipe?.portion} porsi',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            Text(
                                              'Porsi',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 40,
                                          width: 1,
                                          color: Colors.grey[300],
                                        ),
                                        Column(
                                          children: [
                                            Icon(Icons.restaurant_menu,
                                                color: Colors.orange[600],
                                                size: 24),
                                            SizedBox(height: 4),
                                            Text(
                                              '${recipe?.ingredients.length ?? 0}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            Text(
                                              'Bahan',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 24),

                                  // Description
                                  Text(
                                    'Deskripsi',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    recipe?.description ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      height: 1.5,
                                    ),
                                  ),

                                  SizedBox(height: 24),

                                  // Ingredients
                                  Text(
                                    'Bahan-bahan',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  ...recipe?.ingredients
                                          .map((ingredient) => Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 8),
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.grey[200]!),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.orange[600],
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        ingredient.name,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.grey[800],
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${ingredient.quantity} ${ingredient.unit}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Colors.orange[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ))
                                          .toList() ??
                                      [],

                                  SizedBox(height: 24),

                                  // Steps
                                  Text(
                                    'Cara Memasak',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  ...getStepsList()
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    String step = entry.value;
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: Colors.orange[600],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                step.replaceFirst(
                                                    RegExp(r'^\d+\.\s*'), ''),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[700],
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
