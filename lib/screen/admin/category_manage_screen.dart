import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/category_manage_provider.dart';
import 'package:group_project/providers/user_provider.dart';

class CategoryManageScreen extends ConsumerStatefulWidget {
  const CategoryManageScreen({super.key});

  @override
  ConsumerState<CategoryManageScreen> createState() =>
      _CategoryManageScreenState();
}

class _CategoryManageScreenState extends ConsumerState<CategoryManageScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(categoryManageProvider.notifier).fetchCategories(),
    );
  }

  void _showCategoryForm({Map<String, dynamic>? category}) {
    final nameController = TextEditingController(text: category?['name'] ?? '');
    final descriptionController = TextEditingController(
      text: category?['description'] ?? '',
    );
    final imageUrlController = TextEditingController(
      text: category?['image_url'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authState = ref.read(userProvider);
              final token = authState?.token;

              if (token == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Not authenticated')),
                );
                return;
              }

              final success = await ref
                  .read(categoryManageProvider.notifier)
                  .saveCategory(
                    {
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'image_url': imageUrlController.text,
                    },
                    id: category?['id'],
                    token: token,
                  );

              if (success) {
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryManageProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Manage Categories',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: maincolor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: categoriesState.when(
        data: (categories) => ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: cat['image_url'] != null && cat['image_url'].isNotEmpty
                    ? Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(cat['image_url']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: maincolor.withOpacity(0.1),
                        child: Icon(Icons.category, color: maincolor),
                      ),
                title: Text(cat['name'] ?? 'Unnamed'),
                subtitle: Text(
                  cat['description'] ?? 'No description',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showCategoryForm(category: cat),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Category'),
                            content: const Text(
                              'Are you sure? All meals in this category will be affected.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final authState = ref.read(userProvider);
                                  final token = authState?.token;
                                  if (token != null) {
                                    ref
                                        .read(categoryManageProvider.notifier)
                                        .deleteCategory(cat['id'], token);
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(),
        backgroundColor: maincolor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
