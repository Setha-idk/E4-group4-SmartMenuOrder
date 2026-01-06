import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'user_provider.dart';

class Order {
  final int id;
  final String orderNumber;
  final double totalAmount;
  final String status;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'],
      createdAt: json['created_at'],
      items: (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class OrderItem {
  final int id;
  final String mealName;
  final int quantity;
  final double price;
  final String mealImage;

  OrderItem({
    required this.id,
    required this.mealName,
    required this.quantity,
    required this.price,
    required this.mealImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      mealName: json['meal'] != null ? json['meal']['name'] : 'Unknown Meal',
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      mealImage: json['meal'] != null ? json['meal']['image_url'] : '',
    );
  }
}

class OrderNotifier extends StateNotifier<List<Order>> {
  OrderNotifier(this.ref) : super([]);

  final Ref ref;
  bool isLoading = false;
  String? errorMessage; // Added error message field

  Future<void> fetchOrders() async {
    // ... existing fetchOrders code ...
    final user = ref.read(userProvider);
    final token = ref.read(userProvider.notifier).token;

    if (user == null || token == null) return;

    isLoading = true;
    errorMessage = null;
    try {
      final response = await http.get(
        Uri.parse('${UserNotifier.baseUrl}/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> ordersJson = data['orders'];
        state = ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        print('Failed to fetch orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      isLoading = false;
    }
  }
  
  // Place a new order
  Future<bool> placeOrder(List<Map<String, dynamic>> items, double total) async {
    final user = ref.read(userProvider);
    final token = ref.read(userProvider.notifier).token;

    errorMessage = null; // Reset error
    if (user == null || token == null) {
        errorMessage = 'User not logged in';
        return false;
    }

    isLoading = true;
    try {
      final response = await http.post(
        Uri.parse('${UserNotifier.baseUrl}/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'total_amount': total,
          'items': items,
        }),
      );

      print('Place Order Status: ${response.statusCode}');
      print('Place Order Response: ${response.body}');

      if (response.statusCode == 201) {
        // Refresh orders list
        await fetchOrders();
        return true;
      } else {
        final body = jsonDecode(response.body);
        errorMessage = body['message'] ?? 'Failed to place order';
        if (body['errors'] != null) {
            errorMessage = body['errors'].values.first[0];
        }
        return false;
      }
    } catch (e) {
      print('Error placing order: $e');
      errorMessage = 'Connection error: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }
  // Update Order Status
  Future<bool> updateOrderStatus(int orderId, String status) async {
    final user = ref.read(userProvider);
    if (user == null || user.token == null) return false;

    try {
      final response = await http.put(
        Uri.parse('${UserNotifier.baseUrl}/orders/$orderId'),
         headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
          'Accept': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        await fetchOrders(); // Refresh list
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  return OrderNotifier(ref);
});
