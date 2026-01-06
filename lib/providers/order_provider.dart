import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/providers/user_provider.dart';

class OrderModel {
  final int id;
  final String mealName;
  final int quantity;
  final String status;

  OrderModel({
    required this.id,
    required this.mealName,
    required this.quantity,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      mealName: json['meal_name'] ?? 'Unknown',
      quantity: json['quantity'] ?? 1,
      status: json['status'] ?? 'pending',
    );
  }
}

class OrderNotifier extends StateNotifier<List<OrderModel>> {
  OrderNotifier() : super([]);

  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api/admin'));

  Future<void> fetchMyOrders(String? token) async {
    if (token == null) return;

    try {
      final response = await _dio.get(
        '/orders',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        // Crucial: Update the state with the new list
        state = data.map((e) => OrderModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Order Fetch Error: $e");
    }
  }

  Future<bool> cancelOrder(String? token, int orderId) async {
    if (token == null) return false;
    try {
      await _dio.delete(
        '/orders/$orderId/cancel',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      await fetchMyOrders(token);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final orderHistoryProvider =
    StateNotifierProvider<OrderNotifier, List<OrderModel>>((ref) {
      return OrderNotifier();
    });
