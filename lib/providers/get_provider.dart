import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Configure your Laravel backend URL here
const String apiBaseUrl =
    'http://localhost:8000/api'; // Change this to your backend URL

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
      'meal': 'Spaghetti Carbonara',
      'category': 'Pasta',
      'mealThumb':
          'https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg',
      'tags': 'Italian, Creamy',
      'instructions':
          'Cook pasta according to package directions. In a bowl, whisk eggs, cheese, and pepper. Drain pasta and immediately mix with egg mixture. Add cooked bacon and serve.',
    },
    {
      'id': 2,
      'meal': 'Margherita Pizza',
      'category': 'Pizza',
      'mealThumb':
          'https://www.themealdb.com/images/media/meals/x0lk931587671540.jpg',
      'tags': 'Italian, Vegetarian',
      'instructions':
          'Prepare pizza dough. Spread tomato sauce, add mozzarella cheese and fresh basil. Bake at 450°F for 12-15 minutes.',
    },
    {
      'id': 3,
      'meal': 'Caesar Salad',
      'category': 'Salad',
      'mealThumb':
          'https://www.themealdb.com/images/media/meals/n7qnkb1630444129.jpg',
      'tags': 'Healthy, Fresh',
      'instructions':
          'Toss romaine lettuce with Caesar dressing. Add croutons and parmesan cheese. Top with grilled chicken if desired.',
    },
    {
      'id': 4,
      'meal': 'Cheeseburger',
      'category': 'Burger',
      'mealThumb':
          'https://www.themealdb.com/images/media/meals/k420tj1585565244.jpg',
      'tags': 'American, Classic',
      'instructions':
          'Grill beef patty. Toast buns. Add cheese, lettuce, tomato, and condiments. Serve with fries.',
    },
    {
      'id': 5,
      'meal': 'Chicken Tikka',
      'category': 'Indian',
      'mealThumb':
          'https://www.themealdb.com/images/media/meals/wyxwsp1486979827.jpg',
      'tags': 'Spicy, Grilled',
      'instructions':
          'Marinate chicken in yogurt and spices. Grill until cooked through. Serve with naan bread and mint chutney.',
    },
    {
      'id': 6,
      'meal': 'Pad Thai',
      'category': 'Thai',
      'mealThumb':
          'https://www.themealdb.com/images/media/meals/wvtzq31574776223.jpg',
      'tags': 'Asian, Noodles',
      'instructions':
          'Stir-fry rice noodles with eggs, vegetables, and shrimp. Add tamarind sauce and peanuts.',
    },
    {
      'id': 7,
      'meal': 'Chocolate Cake',
      'category': 'Dessert',
      'mealThumb':
          'https://www.themealdb.com/images/media/meals/xqrwyr1511638750.jpg',
      'tags': 'Sweet, Chocolate',
      'instructions':
          'Mix flour, sugar, cocoa, eggs, and butter. Bake at 350°F for 30 minutes. Frost with chocolate ganache.',
    },
    {
      'id': 8,
      'meal': 'Sushi Roll',
      'category': 'Japanese',
      'mealThumb':
          'https://www.themealdb.com/images/media/meals/g046bb1663960946.jpg',
      'tags': 'Seafood, Fresh',
      'instructions':
          'Prepare sushi rice. Roll with nori, cucumber, avocado, and salmon. Slice and serve with soy sauce.',
    },
  ];
}

// Mock data for categories (fallback when backend is not available)
List<Map<String, dynamic>> _getMockCategories() {
  return [
    {'category': 'Pasta'},
    {'category': 'Pizza'},
    {'category': 'Salad'},
    {'category': 'Burger'},
    {'category': 'Indian'},
    {'category': 'Thai'},
    {'category': 'Dessert'},
    {'category': 'Japanese'},
  ];
}
