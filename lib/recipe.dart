// lib/screen/recipe.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab3/consent/colors.dart';
import 'package:lab3/database/app_database.dart';
import 'package:lab3/database/meal_entity.dart';

class Recipe extends ConsumerStatefulWidget {
  final Map<String, dynamic> meal;
  const Recipe({super.key, required this.meal});

  @override
  ConsumerState<Recipe> createState() => _RecipeState();
}

class _RecipeState extends ConsumerState<Recipe> {
  AppDatabase? database;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    database = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .build();
    _listenToFavoriteStatus();
  }

  void _listenToFavoriteStatus() {
    final String id = (widget.meal['id'] ?? widget.meal['idMeal'] ?? '').toString();

    if (id.isEmpty) return;

    database?.mealDao.findMealById(id).listen((meal) {
      if (mounted) {
        setState(() {
          isFavorite = meal != null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List ingredients = widget.meal['ingredients'] ?? [];
    final String instructions = widget.meal['instructions'] ?? 'No instructions provided.';
    final String tagsString = widget.meal['tags'] ?? '';
    final String category = widget.meal['category'] ?? 'General';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('images/background_img.png', fit: BoxFit.cover),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: maincolor,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black,
                        ),
                        onPressed: () async {
                          if (database == null) return;

                          final String id = (widget.meal['id'] ?? widget.meal['idMeal'] ?? '').toString();
                          if (id.isEmpty) return;

                          final favorite = FavoriteMeal(id: id);

                          if (isFavorite) {
                            await database!.mealDao.deleteMeal(favorite);
                          } else {
                            await database!.mealDao.insertMeal(favorite);
                          }
                        },
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    widget.meal['mealThumb'] ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.meal['meal'] ?? 'No Name',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: font, fontFamily: 'ro'),
                      ),
                      const SizedBox(height: 10),
                      // RESTORED CATEGORY TEXT
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: maincolor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (tagsString.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Tags: $tagsString", style: TextStyle(color: maincolor, fontStyle: FontStyle.italic)),
                        ),
                      const Divider(height: 40),
                      Text("Ingredients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: font)),
                      ...ingredients.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: maincolor, size: 18),
                                const SizedBox(width: 10),
                                Expanded(child: Text("${item['ingredient']} - ${item['measure']}", style: TextStyle(color: font))),
                              ],
                            ),
                          )),
                      const Divider(height: 40),
                      Text("Instructions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: font)),
                      Text(instructions, style: TextStyle(fontSize: 16, color: font, height: 1.5)),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}