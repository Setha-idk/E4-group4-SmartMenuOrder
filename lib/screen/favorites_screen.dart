import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/appbar.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/favorite_provider.dart';
import 'package:group_project/providers/get_provider.dart';
import 'package:group_project/screen/detail.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoriteProvider);
    final mealsAsync = ref.watch(mealsProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: appbar(),
      body: mealsAsync.when(
        data: (meals) {
          // Filter the meals to get only the favorited ones
          final favoriteMeals = meals
              .where((meal) => favoriteIds.contains(meal['id'].toString()))
              .toList();

          if (favoriteMeals.isEmpty) {
            return const Center(
              child: Text(
                'You have no favorite meals yet.',
                style: TextStyle(fontSize: 18, color: font),
              ),
            );
          }

          // Display the favorited meals in a grid
          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: favoriteMeals.length,
            itemBuilder: (context, index) =>
                _buildMealCard(context, ref, favoriteMeals[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const Center(child: Text("Error loading meals")),
      ),
    );
  }

  // Replicated from category.dart for consistent UI
  Widget _buildMealCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> meal,
  ) {
    final String category = (meal['category'] is Map)
        ? (meal['category']['name'] ?? 'General')
        : (meal['category']?.toString() ?? 'General');
    final String tags = meal['tags'] ?? '';
    final String mealId = meal['id'].toString();
    final bool isFavorite = ref.watch(favoriteProvider).contains(mealId);

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
          final titleSize = (cardHeight * 0.07).clamp(minTitleSize, 20.0);
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
                            image: NetworkImage(meal['image_url'] ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        meal['name'] ?? '',
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
                          vertical: 4,
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
                        ref
                            .read(favoriteProvider.notifier)
                            .toggleFavorite(mealId);
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
