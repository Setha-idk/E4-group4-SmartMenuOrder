// lib/screen/favorite.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab3/consent/appbar.dart';
import 'package:lab3/consent/colors.dart';
import 'package:lab3/database/app_database.dart';
import 'package:lab3/database/meal_entity.dart';
import 'package:lab3/providers/get_provider.dart';
import 'package:lab3/screen/recipe.dart';

class FavoritesBody extends ConsumerStatefulWidget {
  const FavoritesBody({super.key});

  @override
  ConsumerState<FavoritesBody> createState() => _FavoritesBodyState();
}

class _FavoritesBodyState extends ConsumerState<FavoritesBody> {
  AppDatabase? database;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initDatabase() async {
    database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(mealsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appbar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('images/background_img.png', fit: BoxFit.cover),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "Search your favorites...",
                      prefixIcon: Icon(Icons.search, color: maincolor),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => searchQuery = "");
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text("My Favorites", style: TextStyle(fontSize: 20, color: font, fontWeight: FontWeight.bold, fontFamily: 'ro')),
              ),
              Expanded(
                child: database == null
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<List<FavoriteMeal>>(
                        stream: database!.mealDao.findAllFavoritesAsStream(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                          final favoriteIds = snapshot.data!.map((e) => e.id).toSet();

                          return mealsAsync.when(
                            data: (allMeals) {
                              final favoriteMeals = allMeals.where((m) {
                                final id = (m['id'] ?? m['idMeal'] ?? '').toString();
                                if (!favoriteIds.contains(id)) return false;

                                final name = (m['meal'] ?? "").toString().toLowerCase();
                                final category = (m['category'] ?? "").toString().toLowerCase();
                                return name.contains(searchQuery) || category.contains(searchQuery);
                              }).toList();

                              if (favoriteMeals.isEmpty) {
                                return Center(child: Text(searchQuery.isEmpty ? "No favorites yet" : "No results for '$searchQuery'", style: TextStyle(color: font)));
                              }

                              return GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisExtent: 280,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: favoriteMeals.length,
                                itemBuilder: (context, index) => _buildFavoriteCard(context, favoriteMeals[index]),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, s) => const Center(child: Text("Error loading data")),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, Map<String, dynamic> meal) {
    final String tags = meal['tags'] ?? '';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Recipe(meal: meal))),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(5, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(image: NetworkImage(meal['mealThumb'] ?? ''), fit: BoxFit.cover),
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () async {
                      final id = (meal['id'] ?? meal['idMeal'] ?? '').toString();
                      await database?.mealDao.deleteMeal(FavoriteMeal(id: id));
                    },
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white.withOpacity(0.8),
                      child: const Icon(Icons.favorite, color: Colors.red, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(meal['meal'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(meal['category'] ?? '', style: TextStyle(fontSize: 12, color: maincolor, fontWeight: FontWeight.bold)),
            ),
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('tag: $tags', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: font.withValues(alpha: 0.6), fontStyle: FontStyle.italic)),
              ),
          ],
        ),
      ),
    );
  }
}