import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Configure your Laravel backend URL here
// For localhost: http://localhost:8000/api
// For Android Emulator: http://10.0.2.2:8000/api
// For Physical Device: http://YOUR_PC_IP:8000/api
const String apiBaseUrl = 'http://127.0.0.1:8000/api'; // Android Emulator

// Provider for fetching meals data
final mealsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final response = await http.get(Uri.parse('$apiBaseUrl/meals'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      // If API fails, return mock data as fallback
      return _getMockMeals();
    }
  } catch (e) {
    // If network error or API not available, return mock data
    return _getMockMeals();
  }
});

// Provider for fetching categories data
final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  try {
    final response = await http.get(Uri.parse('$apiBaseUrl/categories'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      // If API fails, return mock data as fallback
      return _getMockCategories();
    }
  } catch (e) {
    // If network error or API not available, return mock data
    return _getMockCategories();
  }
});

// Mock data for meals (fallback when backend is not available)
List<Map<String, dynamic>> _getMockMeals() {
  return [
    {
      'id': 1,
      'category_id': 1,
      'name': 'Spaghetti Carbonara',
      'category': 'Pasta',
      'image_url':
          'https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg',
      'tags': 'Italian, Creamy',
      'description':
          'Classic Italian pasta with eggs, cheese, bacon, and black pepper.',
    },
    {
      'id': 2,
      'category_id': 2,
      'name': 'Margherita Pizza',
      'category': 'Pizza',
      'image_url':
          'https://www.themealdb.com/images/media/meals/x0lk931587671540.jpg',
      'tags': 'Italian, Vegetarian',
      'description':
          'Traditional pizza with tomato sauce, mozzarella, and fresh basil.',
    },
    {
      'id': 3,
      'category_id': 3,
      'name': 'Caesar Salad',
      'category': 'Salad',
      'image_url':
          'https://www.themealdb.com/images/media/meals/n7qnkb1630444129.jpg',
      'tags': 'Healthy, Fresh',
      'description':
          'Crisp romaine lettuce with Caesar dressing, croutons, and parmesan.',
    },
    {
      'id': 4,
      'category_id': 4,
      'name': 'Cheeseburger',
      'category': 'Burger',
      'image_url':
          'https://www.themealdb.com/images/media/meals/k420tj1585565244.jpg',
      'tags': 'American, Classic',
      'description':
          'Juicy beef patty with cheese, lettuce, tomato, and special sauce.',
    },
    {
      'id': 5,
      'category_id': 5,
      'name': 'Chicken Tikka',
      'category': 'Indian',
      'image_url':
          'https://www.themealdb.com/images/media/meals/wyxwsp1486979827.jpg',
      'tags': 'Spicy, Grilled',
      'description': 'Tender chicken in a creamy tomato-based curry sauce.',
    },
    {
      'id': 6,
      'category_id': 6,
      'name': 'Pad Thai',
      'category': 'Thai',
      'image_url':
          'https://www.themealdb.com/images/media/meals/wvtzq31574776223.jpg',
      'tags': 'Asian, Noodles',
      'description': 'Stir-fried rice noodles with shrimp, eggs, and peanuts.',
    },
    {
      'id': 7,
      'category_id': 7,
      'name': 'Chocolate Cake',
      'category': 'Dessert',
      'image_url':
          'https://www.themealdb.com/images/media/meals/xqrwyr1511638750.jpg',
      'tags': 'Sweet, Chocolate',
      'description': 'Warm chocolate cake with a molten chocolate center.',
    },
    {
      'id': 8,
      'category_id': 8,
      'name': 'Sushi Roll',
      'category': 'Japanese',
      'image_url':
          'https://www.themealdb.com/images/media/meals/g046bb1663960946.jpg',
      'tags': 'Seafood, Fresh',
      'description': 'Sushi roll with crab, avocado, and cucumber.',
    },
  ];
}

// Mock data for categories (fallback when backend is not available)
List<Map<String, dynamic>> _getMockCategories() {
  return [
    {'id': 1, 'name': 'Pasta'},
    {'id': 2, 'name': 'Pizza'},
    {'id': 3, 'name': 'Salad'},
    {'id': 4, 'name': 'Burger'},
    {'id': 5, 'name': 'Indian'},
    {'id': 6, 'name': 'Thai'},
    {'id': 7, 'name': 'Dessert'},
    {'id': 8, 'name': 'Japanese'},
  ];
}
