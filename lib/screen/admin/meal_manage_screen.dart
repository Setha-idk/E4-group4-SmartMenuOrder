import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/providers/meal_manage_provider.dart';
import 'package:group_project/providers/user_provider.dart';

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
          )
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
                  meal['mealThumb'] ?? '', 
                  width: 50, 
                  errorBuilder: (c, e, s) => const Icon(Icons.fastfood)
                ),
                title: Text(meal['meal'] ?? 'Unknown'),
                subtitle: Text("\$${meal['price']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit), 
                      onPressed: () => _showMealForm(context, ref, user?.token, meal: meal)
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
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

  void _showMealForm(BuildContext context, WidgetRef ref, String? token, {Map<String, dynamic>? meal}) {
    final nameController = TextEditingController(text: meal?['name']);
    final priceController = TextEditingController(text: meal?['price']?.toString());
    // ... Add other controllers for category_id, description, image_url

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(meal == null ? "Add Meal" : "Edit Meal"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
              // ... Add other fields
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final data = {
                "name": nameController.text,
                "price": priceController.text,
                "category_id": 1, // Example: logic to select category needed
                "description": "Description here",
                "image_url": "https://example.com/image.jpg",
              };
              final success = await ref.read(mealManageProvider.notifier).saveMeal(data, id: meal?['id'], token: token!);
              if (success) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}