import 'package:flutter/material.dart';
import 'package:group_project/consent/appbar.dart';
import 'package:group_project/consent/colors.dart';

class Recipe extends StatelessWidget {
  final Map<String, dynamic> meal;

  const Recipe({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final String mealName = meal['meal'] ?? 'Unknown Meal';
    final String category = meal['category'] ?? 'General';
    final String imageUrl = meal['mealThumb'] ?? '';
    final String instructions =
        meal['instructions'] ?? 'No instructions available.';
    final String tags = meal['tags'] ?? '';

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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart!')),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to favorites!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.favorite_border),
                        iconSize: 28,
                        color: maincolor,
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
}
