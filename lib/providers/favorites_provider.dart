import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/providers/user_provider.dart';

// Favorites state notifier
class FavoritesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FavoritesNotifier(this.ref) : super([]);

  final Ref ref;

  // Fetch favorites from API
  Future<void> fetchFavorites() async {
    final token = ref.read(userProvider.notifier).token;
    print('Fetching favorites... Token avail: ${token != null}');
    if (token == null) return;

    try {
      final url = '${UserNotifier.baseUrl}/favorites';
      print('GET $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      print('Fetch Favorites Response: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> meals = data['favorites'];
        // Ensure data type is correct
        final mappedMeals = meals.map((m) => Map<String, dynamic>.from(m)).toList();
        state = mappedMeals;
        print('Favorites updated. Count: ${state.length}');
      }
    } catch (e) {
      print('Error fetching favorites: $e');
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Map<String, dynamic> meal) async {
    final token = ref.read(userProvider.notifier).token;
    final mealId = meal['id'];
    
    // Check if currently favorite
    final wasFavorite = isFavorite(mealId);

    // Optimistic Update (Immediate UI change)
    if (wasFavorite) {
      state = state.where((item) => item['id'] != mealId).toList();
    } else {
      state = [...state, meal];
    }
    
    // If guest/offline, stop here (local only)
    if (token == null) return; 

    try {
      if (wasFavorite) {
          // Remove from backend
          await http.delete(
             Uri.parse('${UserNotifier.baseUrl}/favorites/$mealId'),
             headers: {
                 'Authorization': 'Bearer $token',
                 'Accept': 'application/json',
             },
          );
      } else {
          // Add to backend
          await http.post(
             Uri.parse('${UserNotifier.baseUrl}/favorites'),
             headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
                'Accept': 'application/json',
             },
             body: jsonEncode({'meal_id': mealId}),
          );
      }
    } catch (e) {
      print('Error syncing favorite: $e');
      // Optionally revert state here if strict consistency needed
    }
  }

  // Check if item is favorited
  bool isFavorite(int id) {
    return state.any((item) => item['id'] == id);
  }

  // Get favorites count
  int getCount() {
    return state.length;
  }
  
  // Clear favorites (on logout)
  void clear() {
    state = [];
  }
}

// Favorites provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Map<String, dynamic>>>((ref) {
  return FavoritesNotifier(ref);
});

// Favorites count provider
final favoritesCountProvider = Provider<int>((ref) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.length;
});

// Check if item is favorite provider
final isFavoriteProvider = Provider.family<bool, int>((ref, mealId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.any((item) => item['id'] == mealId);
});
