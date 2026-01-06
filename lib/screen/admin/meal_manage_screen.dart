import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/providers/meal_manage_provider.dart';
import 'package:group_project/providers/user_provider.dart';
import 'package:group_project/providers/get_provider.dart';

class MealManageScreen extends ConsumerStatefulWidget {
  const MealManageScreen({super.key});

  @override
  ConsumerState<MealManageScreen> createState() => _MealManageScreenState();
}

class _MealManageScreenState extends ConsumerState<MealManageScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the API call as soon as the screen opens
    Future.microtask(() => ref.read(mealManageProvider.notifier).fetchMeals());
  }

  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(mealManageProvider);
    final user = ref.read(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Meals"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(mealManageProvider.notifier).fetchMeals(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMealForm(context, ref, user?.token),
        child: const Icon(Icons.add),
      ),
      body: mealsAsync.when(
        data: (meals) => RefreshIndicator(
          onRefresh: () => ref.read(mealManageProvider.notifier).fetchMeals(),
          child: ListView.builder(
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return ListTile(
                leading: Image.network(
                  meal['image_url'] ?? '',
                  width: 50,
                  errorBuilder: (c, e, s) => const Icon(Icons.fastfood),
                ),
                title: Text(meal['name'] ?? 'Unknown'),
                subtitle: Text("\$${meal['price']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showMealForm(context, ref, user?.token, meal: meal),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(meal['id'], user?.token),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  void _confirmDelete(int id, String? token) {
    if (token == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Meal?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              ref.read(mealManageProvider.notifier).deleteMeal(id, token);
              Navigator.pop(context);
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMealForm(
    BuildContext context,
    WidgetRef ref,
    String? token, {
    Map<String, dynamic>? meal,
  }) {
    final nameController = TextEditingController(text: meal?['name']);
    final priceController = TextEditingController(
      text: meal?['price']?.toString(),
    );
    final descriptionController = TextEditingController(
      text: meal?['description'],
    );
    final imageUrlController = TextEditingController(text: meal?['image_url']);
    final tagsController = TextEditingController(text: meal?['tags']);

    // Parse initial values
    int? selectedCategoryId = meal?['category_id'] != null
        ? int.tryParse(meal!['category_id'].toString())
        : null;

    // Handle is_available mostly as boolean but be safe
    bool isAvailable = true;
    if (meal != null) {
      if (meal['is_available'] is bool) {
        isAvailable = meal['is_available'];
      } else if (meal['is_available'] is int) {
        isAvailable = meal['is_available'] == 1;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final notifier = ref.read(mealManageProvider.notifier);

          return AlertDialog(
            title: Text(meal == null ? "Add Meal" : "Edit Meal"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      errorText: notifier.fieldErrors?['name'] != null
                          ? notifier.fieldErrors!['name'][0]
                          : null,
                    ),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: "Price",
                      errorText: notifier.fieldErrors?['price'] != null
                          ? notifier.fieldErrors!['price'][0]
                          : null,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      errorText: notifier.fieldErrors?['description'] != null
                          ? notifier.fieldErrors!['description'][0]
                          : null,
                    ),
                    maxLines: 3,
                  ),
                  TextField(
                    controller: imageUrlController,
                    decoration: InputDecoration(
                      labelText: "Image URL",
                      errorText: notifier.fieldErrors?['image_url'] != null
                          ? notifier.fieldErrors!['image_url'][0]
                          : null,
                    ),
                  ),
                  TextField(
                    controller: tagsController,
                    decoration: InputDecoration(
                      labelText: "Tags (comma separated)",
                      errorText: notifier.fieldErrors?['tags'] != null
                          ? notifier.fieldErrors!['tags'][0]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Category Dropdown
                  Consumer(
                    builder: (context, ref, child) {
                      final categoriesAsync = ref.watch(categoriesProvider);
                      return categoriesAsync.when(
                        data: (categories) {
                          return DropdownButtonFormField<int>(
                            value: selectedCategoryId,
                            decoration: InputDecoration(
                              labelText: "Category",
                              errorText:
                                  notifier.fieldErrors?['category_id'] != null
                                  ? notifier.fieldErrors!['category_id'][0]
                                  : null,
                            ),
                            items: categories.map((cat) {
                              return DropdownMenuItem<int>(
                                value: int.tryParse(cat['id'].toString()),
                                child: Text(cat['name'].toString()),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setDialogState(() => selectedCategoryId = val);
                            },
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) =>
                            const Text("Error loading categories"),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text("Is Available"),
                    value: isAvailable,
                    onChanged: (val) => setDialogState(() => isAvailable = val),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedCategoryId == null) {
                    setDialogState(() {
                      notifier.fieldErrors = {
                        'category_id': ['Please select a category'],
                      };
                    });
                    return;
                  }

                  final data = {
                    "name": nameController.text,
                    "price": priceController.text,
                    "category_id": selectedCategoryId,
                    "description": descriptionController.text,
                    "image_url": imageUrlController.text,
                    "tags": tagsController.text,
                    "is_available": isAvailable,
                  };

                  final success = await notifier.saveMeal(
                    data,
                    id: meal?['id'],
                    token: token!,
                  );
                  if (success) {
                    Navigator.pop(context);
                  } else {
                    setDialogState(() {}); // Rebuild to show errors
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }
}
