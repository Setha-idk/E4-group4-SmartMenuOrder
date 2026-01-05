import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http; // Will be used later
// import 'dart:convert'; // Will be used later

// 1. Provider for SharedPreferences
// We'll override this in main.dart after initializing SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// 2. The State Notifier for Favorites
class FavoriteNotifier extends StateNotifier<List<String>> {
  final SharedPreferences _prefs;
  
  // TODO: Replace with your actual User/Auth provider
  bool _isLoggedIn = false;

  FavoriteNotifier(this._prefs) : super([]) {
    _loadFavorites();
  }

  void _loadFavorites() {
    if (_isLoggedIn) {
      // TODO: Fetch favorites from Laravel API
      // state = await _fetchFavoritesFromApi();
    } else {
      // Load from local storage for guests
      state = _prefs.getStringList('guest_favorites') ?? [];
    }
  }

  void toggleFavorite(String itemId) {
    // Check if the item is already a favorite
    if (state.contains(itemId)) {
      // If it is, create a new list without that item
      state = state.where((id) => id != itemId).toList();
    } else {
      // If it isn't, create a new list with that item added
      state = [...state, itemId];
    }

    if (_isLoggedIn) {
      // TODO: Call API to update favorites on the backend
      // _updateFavoritesOnApi(state);
    } else {
      // Save to local storage for guests
      _prefs.setStringList('guest_favorites', state);
    }
  }

  Future<void> syncFavoritesOnLogin() async {
    final List<String> guestFavorites = _prefs.getStringList('guest_favorites') ?? [];

    if (guestFavorites.isNotEmpty) {
      // TODO: Send guestFavorites to your Laravel backend API
      // await http.post(Uri.parse('YOUR_API_ENDPOINT/sync-favorites'), body: json.encode({'item_ids': guestFavorites}));
      
      await _prefs.remove('guest_favorites');
    }

    _isLoggedIn = true;
    _loadFavorites();
  }
  
  void onLogout() {
    _isLoggedIn = false;
    state = _prefs.getStringList('guest_favorites') ?? []; // Revert to guest favorites
  }
}

// 3. The StateNotifierProvider for the UI to use
final favoriteProvider = StateNotifierProvider<FavoriteNotifier, List<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FavoriteNotifier(prefs);
});