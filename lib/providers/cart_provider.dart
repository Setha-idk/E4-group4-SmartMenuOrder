import 'package:flutter_riverpod/flutter_riverpod.dart';

// Cart item model
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
}

// Cart state notifier
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  // Add item to cart
  void addItem(Map<String, dynamic> meal) {
    final existingIndex = state.indexWhere((item) => item.id == meal['id']);

    if (existingIndex >= 0) {
      // Item exists, increase quantity
      final updatedCart = [...state];
      updatedCart[existingIndex].quantity++;
      state = updatedCart;
    } else {
      // New item, add to cart
      state = [
        ...state,
        CartItem(
          id: meal['id'],
          name: meal['meal'],
          category: meal['category'],
          price: double.tryParse(meal['price']?.toString() ?? '0') ?? 0,
          imageUrl: meal['mealThumb'] ?? '',
        ),
      ];
    }
  }

  // Remove item from cart
  void removeItem(int id) {
    state = state.where((item) => item.id != id).toList();
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
  }

  // Clear cart
  void clearCart() {
    state = [];
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

// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Total price provider
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (total, item) => total + (item.price * item.quantity));
});

// Total items count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (total, item) => total + item.quantity);
});
