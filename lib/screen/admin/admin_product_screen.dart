import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/get_provider.dart';
import 'package:group_project/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AdminProductScreen extends ConsumerStatefulWidget {
  const AdminProductScreen({super.key});

  @override
  ConsumerState<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends ConsumerState<AdminProductScreen> {
  // Delete meal
  Future<void> _deleteMeal(int id) async {
    final user = ref.read(userProvider);
    if (user == null || user.token == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse('${UserNotifier.baseUrl}/meals/$id'),
          headers: {
            'Authorization': 'Bearer ${user.token}',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          // ignore: unused_result
          ref.refresh(mealsProvider);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal deleted')));
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: ${response.statusCode}')));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _openEditor({Map<String, dynamic>? meal}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MealEditorScreen(meal: meal)),
    ).then((_) => ref.refresh(mealsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(mealsProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Manage Products', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: maincolor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        backgroundColor: maincolor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: mealsAsync.when(
        data: (meals) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    meal['mealThumb'] ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
                  ),
                ),
                title: Text(meal['meal'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('\$${meal['price']} • ${meal['category']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openEditor(meal: meal),
                    ),
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMeal(meal['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class MealEditorScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? meal;
  const MealEditorScreen({super.key, this.meal});

  @override
  ConsumerState<MealEditorScreen> createState() => _MealEditorScreenState();
}


class _MealEditorScreenState extends ConsumerState<MealEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  // late TextEditingController _imageController; // REMOVED
  late TextEditingController _descController;
  late TextEditingController _tagsController;
  int? _categoryId;
  bool _isLoading = false;
  
  File? _selectedImage;
  String? _currentImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final m = widget.meal;
    _nameController = TextEditingController(text: m?['meal'] ?? '');
    _priceController = TextEditingController(text: m?['price']?.toString() ?? '');
    // _imageController = TextEditingController(text: m?['mealThumb'] ?? '');
    _currentImageUrl = m?['mealThumb'];
    _descController = TextEditingController(text: m?['instructions'] ?? '');
    _tagsController = TextEditingController(text: m?['tags'] ?? '');
    _categoryId = m?['category_id']; // Don't default to 1, let it be null if not editing
  }


  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null && _currentImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image')));
        return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(userProvider);
    final isEditing = widget.meal != null;
    final url = isEditing
        ? '${UserNotifier.baseUrl}/meals/${widget.meal!['id']}'
        : '${UserNotifier.baseUrl}/meals';

    try {
      http.StreamedResponse response;
      
      final request = http.MultipartRequest(isEditing ? 'POST' : 'POST', Uri.parse(url));
      
      // For PUT with Multipart, Laravel sometimes needs _method field
      if (isEditing) request.fields['_method'] = 'PUT';

      request.headers.addAll({
          'Authorization': 'Bearer ${user!.token}',
          'Accept': 'application/json',
      });

      request.fields['meal'] = _nameController.text;
      request.fields['category_id'] = _categoryId.toString();
      request.fields['price'] = _priceController.text;
      request.fields['instructions'] = _descController.text;
      request.fields['tags'] = _tagsController.text;
      if (_currentImageUrl != null) request.fields['mealThumb'] = _currentImageUrl!;

      if (_selectedImage != null) {
         request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
      }

      response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Updated' : 'Created')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${response.statusCode} $respStr')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.meal != null ? 'Edit Meal' : 'Add Meal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
               // Image Picker UI
               GestureDetector(
                 onTap: _pickImage,
                 child: Container(
                   height: 200,
                   width: double.infinity,
                   decoration: BoxDecoration(
                     color: Colors.grey[200],
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: Colors.grey),
                   ),
                   child: _selectedImage != null
                       ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImage!, fit: BoxFit.cover))
                       : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                           ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_currentImageUrl!, fit: BoxFit.cover))
                           : const Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                 Text('Tap to select image'),
                               ],
                             ),
                 ),
               ),
               const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                data: (cats) {
                  // Ensure _categoryId exists in the list, otherwise set to first category or null
                  if (_categoryId != null && !cats.any((c) => c['id'] == _categoryId)) {
                    _categoryId = cats.isNotEmpty ? cats.first['id'] : null;
                  }
                  
                  return DropdownButtonFormField<int>(
                    value: _categoryId, 
                    items: cats.map((c) {
                      return DropdownMenuItem<int>(
                        value: c['id'], 
                        child: Text(c['category'] ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (v) => v == null ? 'Please select a category' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_,__) => const Text('Failed to load categories'),
              ),
              // const SizedBox(height: 16),
              // TextFormField(
              //   controller: _imageController,
              //   decoration: const InputDecoration(labelText: 'Image URL'),
              //   validator: (v) => v!.isEmpty ? 'Required' : null,
              // ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Instructions/Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: maincolor, foregroundColor: Colors.white),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Meal'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
