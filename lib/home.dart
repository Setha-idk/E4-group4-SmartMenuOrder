import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/appbar.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/favorite_provider.dart';
import 'package:group_project/screen/detail.dart';
import 'package:group_project/providers/get_provider.dart';

class Category extends ConsumerStatefulWidget {
  const Category({super.key});

  @override
  ConsumerState<Category> createState() => _CategoryState();
}

class _CategoryState extends ConsumerState<Category> {
  String selectedCategory = "All";
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final mealsAsync = ref.watch(mealsProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: appbar(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
            child: Container(
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: "Search your favorite meal...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
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

          // Category Selector
          categoriesAsync.when(
            data: (categories) {
              final allCategories = [
                "All",
                ...categories.map((c) => (c['name'] ?? 'Unknown').toString()),
              ];
              return SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final category = allCategories[index];
                    final isSelected = selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) =>
                            setState(() => selectedCategory = category),
                        selectedColor: maincolor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(height: 60),
            error: (_, __) => const SizedBox(height: 60),
          ),

          // Meals Grid
          Expanded(
            child: mealsAsync.when(
              data: (meals) {
                final filteredMeals = meals.where((meal) {
                  final mealCat = (meal['category'] is Map)
                      ? (meal['category']['name'] ?? '')
                      : (meal['category']?.toString() ?? '');

                  final matchesCategory =
                      selectedCategory == "All" || mealCat == selectedCategory;
                  final matchesSearch = (meal['meal'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery);
                  return matchesCategory && matchesSearch;
                }).toList();

                if (filteredMeals.isEmpty)
                  return const Center(child: Text("No meals found"));
                return _buildMealGrid(filteredMeals);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealGrid(List<dynamic> filteredMeals) {
    final favorites = ref.watch(favoriteProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(mealsProvider.future),
      child: GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.65,
        ),
        itemCount: filteredMeals.length,
        itemBuilder: (context, index) {
          final meal = filteredMeals[index];

          // --- Data extraction mirrored from detail.dart (Recipe widget) ---
          final String mealName = meal['name'] ?? 'Unknown Meal';
          final String category = (meal['category'] is Map)
              ? (meal['category']['name'] ?? 'General')
              : (meal['category']?.toString() ?? 'General');
          final String imageUrl = meal['image_url'] ?? '';
          final String tags = meal['tags'] ?? '';
          final String mealId = meal['id'].toString();
          final String price = meal['price']?.toString() ?? '0.00';

          final bool isFavorite = favorites.contains(mealId);

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Recipe(meal: meal)),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            image: DecorationImage(
                              image: imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : const AssetImage('assets/placeholder.png')
                                        as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mealName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              category,
                              style: TextStyle(
                                color: font.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                            if (tags.isNotEmpty)
                              Text(
                                tags,
                                style: TextStyle(
                                  color: font.withOpacity(0.4),
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "\$$price",
                                  style: TextStyle(
                                    color: maincolor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: maincolor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        ref
                            .read(favoriteProvider.notifier)
                            .toggleFavorite(mealId);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
