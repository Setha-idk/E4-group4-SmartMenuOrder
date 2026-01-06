// lib/providers/admin_order_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/providers/user_provider.dart';

class AdminOrder {
  final int id;
  final String userName;
  final String phoneNumber; // Added field
  final String mealName;
  final int quantity;
  final String status;

  AdminOrder({
    required this.id,
    required this.userName,
    required this.phoneNumber, // Added to constructor
    required this.mealName,
    required this.quantity,
    required this.status,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    return AdminOrder(
      id: json['id'],
      userName: json['user_name'],
      phoneNumber: json['phone_number'] ?? 'N/A', // Map from JSON
      mealName: json['meal_name'],
      quantity: json['quantity'],
      status: json['status'],
    );
  }
}

class AdminOrderNotifier extends StateNotifier<List<AdminOrder>> {
  AdminOrderNotifier() : super([]);

  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));

  Future<void> fetchOrders(WidgetRef ref) async {
    final user = ref.read(userProvider);
    if (user?.token == null) return;

    try {
      final response = await _dio.get(
        '/admin/orders',
        options: Options(headers: {'Authorization': 'Bearer ${user!.token}'}),
      );
      final List data = response.data;
      state = data.map((json) => AdminOrder.fromJson(json)).toList();
    } catch (e) {
      print("Fetch Error: $e");
    }
  }

  Future<void> updateStatus(WidgetRef ref, int orderId, String newStatus) async {
    final user = ref.read(userProvider);
    if (user?.token == null) return;

    try {
      await _dio.patch(
        '/orders/$orderId/status',
        data: {'status': newStatus},
        options: Options(headers: {'Authorization': 'Bearer ${user!.token}'}),
      );
      // Update local state
      state = [
        for (final order in state)
          if (order.id == orderId)
            AdminOrder(
              id: order.id,
              userName: order.userName,
              phoneNumber: order.phoneNumber,
              mealName: order.mealName,
              quantity: order.quantity,
              status: newStatus,
            )
          else
            order,
      ];
    } catch (e) {
      print("Update Error: $e");
    }
  }
}

final adminOrderProvider = StateNotifierProvider<AdminOrderNotifier, List<AdminOrder>>((ref) => AdminOrderNotifier());