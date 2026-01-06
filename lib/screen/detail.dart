import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/appbar.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/cart_provider.dart';
import 'package:group_project/providers/favorites_provider.dart';
import 'package:group_project/providers/user_provider.dart';
import 'package:group_project/screen/login_screen.dart';

class Recipe extends ConsumerWidget {
  final Map<String, dynamic> meal;

  const Recipe({super.key, required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String mealName = meal['meal'] ?? meal['name'] ?? 'Unknown Meal';
    final String category = meal['category'] ?? 'General';
    final String imageUrl = meal['mealThumb'] ?? meal['image_url'] ?? '';
    final String instructions =
        meal['instructions'] ?? 'No instructions available.';
    final String tags = meal['tags'] ?? '';
    final String mealId = meal['id'].toString();

    // Watch the favorite provider to get the current state
    final favoriteIds = ref.watch(favoritesProvider).map((m) => m['id'].toString()).toList();
    final isFavorite = favoriteIds.contains(mealId);

    return Scaffold(
      backgroundColor: background,
      appBar: appbar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Image
            if (imageUrl.isNotEmpty)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Name
                  Text(
                    mealName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: font,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category
                  Chip(
                    label: Text(
                      category,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: maincolor,
                  ),

                  // Tags
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tags: $tags',
                      style: TextStyle(
                        fontSize: 14,
                        color: font.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Instructions Header
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: font,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Instructions Content
                  Text(
                    instructions,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: font,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final user = ref.read(userProvider);
                            
                            // Check if guest
                            if (user?.isGuest == true) {
                              _showLoginRequiredDialog(context, 'add items to cart');
                              return;
                            }
                            
                            ref.read(cartProvider.notifier).addItem(meal);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$mealName added to cart!'),
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'View Cart',
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maincolor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          final user = ref.read(userProvider);
                          
                          // Check if guest
                          if (user?.isGuest == true) {
                            _showLoginRequiredDialog(context, 'save favorites');
                            return;
                          }
                          
                          final isFav = ref.read(favoritesProvider.notifier).isFavorite(meal['id']);
                          ref.read(favoritesProvider.notifier).toggleFavorite(meal);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFav 
                                  ? '$mealName removed from favorites!' 
                                  : '$mealName added to favorites!',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(
                          ref.watch(isFavoriteProvider(meal['id']))
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        iconSize: 28,
                        color: isFavorite ? Colors.red : maincolor,
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
  }

  void _showLoginRequiredDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: Text('Please login to $action.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: maincolor),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
