import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/appbar.dart';
import 'package:group_project/consent/colors.dart';
// Use the PLURAL provider (Backend connected)
import 'package:group_project/providers/favorites_provider.dart'; 
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
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search name, category, or tags...",
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

          // Filter Chips with BoxShadow
          categoriesAsync.when(
            data: (categories) {
              return SizedBox(
                height: 60, // Increased height to accommodate shadow
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    bool isAll = index == 0;
                    String name =
                        isAll ? "All" : categories[index - 1]['category'];
                    bool isSelected = selectedCategory == name;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: ChoiceChip(
                          label: Text(name),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => selectedCategory = name);
                            }
                          },
                          // Removing default border to make shadow look cleaner
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide.none,
                          ),
                          selectedColor: maincolor,
                          backgroundColor: cardBackground,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : font,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(height: 60),
            error: (e, s) => const SizedBox.shrink(),
          ),

          // Filtered List
          Expanded(
            child: mealsAsync.when(
              data: (meals) {
                final filtered = meals.where((m) {
                  final name = (m['meal']?.toString() ?? "").toLowerCase();
                  final category =
                      (m['category']?.toString() ?? "").toLowerCase();
                  final tags = (m['tags']?.toString() ?? "").toLowerCase();

                  bool matchesCategoryFilter = (selectedCategory == "All") ||
                      category.contains(selectedCategory.toLowerCase());

                  bool matchesSearchQuery = name.contains(searchQuery) ||
                      category.contains(searchQuery) ||
                      tags.contains(searchQuery);

                  return matchesCategoryFilter && matchesSearchQuery;
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _buildMealCard(context, filtered[index]),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, s) =>
                  const Center(child: Text("Error loading meals")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Map<String, dynamic> meal) {
    final String category = meal['category'] ?? 'General';
    final String tags = meal['tags'] ?? '';
    final String mealId = meal['id'].toString();

    // Watch the Backend Favorites Provider
    final favoriteIds = ref.watch(favoritesProvider).map((m) => m['id'].toString()).toList();
    final isFavorite = favoriteIds.contains(mealId);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Recipe(meal: meal)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardHeight = constraints.maxHeight;

          // Define minimum font sizes
          const minTitleSize = 12.0;
          const minCategorySize = 10.0;
          const minTagSize = 8.0;

          // Calculate dynamic font sizes based on card height
          final titleSize = (cardHeight * 0.07).clamp(minTitleSize, 20.0); // Capped at 20
          final categorySize = (cardHeight * 0.05).clamp(minCategorySize, 16.0);
          final tagSize = (cardHeight * 0.04).clamp(minTagSize, 14.0);
          
          final imageHeight = cardHeight * 0.55;

          return Container(
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(5, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        height: imageHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(meal['mealThumb'] ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        meal['meal'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: titleSize,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: categorySize,
                          color: maincolor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        child: Text(
                          tags,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: tagSize,
                            color: font.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    // Price Display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(
                        '\$${meal['price'] ?? '0.00'}',
                        style: TextStyle(
                          fontSize: titleSize * 0.9, // Slightly smaller than title
                          color: maincolor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: cardHeight * 0.1, // Dynamic icon size
                      ),
                      onPressed: () {
                         // Use Plural Provider logic which takes MAP
                         ref.read(favoritesProvider.notifier).toggleFavorite(meal);
                      },
                      splashRadius: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}