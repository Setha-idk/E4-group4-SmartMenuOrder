import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final int id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  // Convert to Map for JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  // Create from Map
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      quantity: json['quantity'],
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    loadCart();
  }

  // Load cart from SharedPreferences
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart_items');
    if (cartString != null) {
      final List<dynamic> cartJson = jsonDecode(cartString);
      state = cartJson.map((item) => CartItem.fromJson(item)).toList();
    }
  }

  // Save cart to SharedPreferences
  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString('cart_items', cartString);
  }

  void addItem(Map<String, dynamic> meal) {
    final existingIndex = state.indexWhere((item) => item.id == meal['id']);
    if (existingIndex >= 0) {
      state[existingIndex].quantity++;
      state = [...state];
    } else {
      state = [
        ...state,
        CartItem(
          id: meal['id'],
          name: meal['meal'],
          category: meal['category'] ?? 'General',
          price: double.tryParse(meal['price']?.toString() ?? '0') ?? 0,
          imageUrl: meal['mealThumb'] ?? '',
        ),
      ];
    }
    saveCart();
  }

  // Remove item from cart
  void removeItem(int id) {
    state = state.where((item) => item.id != id).toList();
    saveCart();
  }

  // Increase quantity
  void increaseQuantity(int id) {
    final updatedCart = state.map((item) {
      if (item.id == id) {
        item.quantity++;
      }
      return item;
    }).toList();
    state = updatedCart;
    saveCart();
  }

  // Decrease quantity
  void decreaseQuantity(int id) {
    final updatedCart = state.map((item) {
      if (item.id == id && item.quantity > 1) {
        item.quantity--;
      }
      return item;
    }).toList();
    state = updatedCart;
    saveCart();
  }

  // Clear cart
  void clearCart() {
    state = [];
    saveCart();
  }

  // Get total price
  double getTotal() {
    return state.fold(0, (total, item) => total + (item.price * item.quantity));
  }

  // Get total items count
  int getItemCount() {
    return state.fold(0, (total, item) => total + item.quantity);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + (item.price * item.quantity));
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});