import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserManageNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  UserManageNotifier() : super(const AsyncValue.loading());

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<void> fetchUsers(String token) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get(
        '/users',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String? errorMessage;
  Map<String, dynamic>? fieldErrors;

  Future<bool> saveUser(
    Map<String, dynamic> data, {
    int? id,
    required String token,
  }) async {
    try {
      errorMessage = null;
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      if (id == null) {
        await _dio.post('/users', data: data, options: options);
      } else {
        await _dio.put('/users/$id', data: data, options: options);
      }
      fetchUsers(token);
      return true;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 422) {
          fieldErrors = e.response?.data['errors'];
          final errors = e.response?.data['errors'];
          if (errors != null && errors is Map) {
            errorMessage = errors.values.first[0].toString();
          } else {
            errorMessage = e.response?.data['message'] ?? 'Validation error';
          }
        } else {
          errorMessage = e.response?.data['message'] ?? 'Error saving user';
        }
      }
      print('Error saving user: $e');
      return false;
    }
  }

  Future<void> deleteUser(int id, String token) async {
    try {
      await _dio.delete(
        '/users/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      fetchUsers(token);
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}

final userManageProvider =
    StateNotifierProvider<UserManageNotifier, AsyncValue<List<dynamic>>>(
      (ref) => UserManageNotifier(),
    );
