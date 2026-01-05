import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/providers/user_provider.dart';

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

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    followRedirects: false,
    validateStatus: (status) => status! < 500,
  ));

  Future<bool> placeOrder(WidgetRef ref) async {
    final user = ref.read(userProvider);
    
    // 1. Debug: Check if user and token exist in state
    if (user == null) {
      print("DEBUG: Order failed - User state is null");
      return false;
    }
    if (user.token == null || user.token!.isEmpty) {
      print("DEBUG: Order failed - Token is null or empty for user: ${user.username}");
      return false;
    }

    final orderData = {
      'user_name': user.username,
      'phone_number': user.phoneNumber,
      'items': state.map((item) => {
        'meal_id': item.id,
        'meal_name': item.name,
        'quantity': item.quantity,
        'price': item.price,
      }).toList(),
    };

    // 2. Debug: Print the full request details
    print("--- API REQUEST START ---");
    print("URL: ${ _dio.options.baseUrl}/orders/batch");
    print("Token: Bearer ${user.token}");
    print("Body: $orderData");
    print("-------------------------");

    try {
      final response = await _dio.post(
        '/orders/batch',
        data: orderData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${user.token}',
          },
        ),
      );

      print("DEBUG: Response Status: ${response.statusCode}");
      print("DEBUG: Response Body: ${response.data}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        clearCart();
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("--- API ERROR ---");
      print("Status Code: ${e.response?.statusCode}");
      print("Error Data: ${e.response?.data}");
      print("Message: ${e.message}");
      return false;
    } catch (e) {
      print("DEBUG: General Error: $e");
      return false;
    }
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
          category: meal['category'],
          price: double.tryParse(meal['price']?.toString() ?? '0') ?? 0,
          imageUrl: meal['mealThumb'] ?? '',
        ),
      ];
    }
  }

  void removeItem(int id) => state = state.where((item) => item.id != id).toList();
  void clearCart() => state = [];
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