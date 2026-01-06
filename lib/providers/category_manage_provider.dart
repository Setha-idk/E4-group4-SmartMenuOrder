import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryManageNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  CategoryManageNotifier() : super(const AsyncValue.loading());

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  String? errorMessage;
  Map<String, dynamic>? fieldErrors;

  Future<void> fetchCategories() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/categories');
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveCategory(
    Map<String, dynamic> data, {
    int? id,
    required String token,
  }) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      if (id == null) {
        await _dio.post('/categories', data: data, options: options);
      } else {
        await _dio.put('/categories/$id', data: data, options: options);
      }
      fetchCategories();
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
          errorMessage = e.response?.data['message'] ?? 'Error saving category';
        }
      }
      print('Error saving category: $e');
      return false;
    }
  }

  Future<void> deleteCategory(int id, String token) async {
    try {
      await _dio.delete(
        '/categories/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      fetchCategories();
    } catch (e) {
      print('Error deleting category: $e');
    }
  }
}

final categoryManageProvider =
    StateNotifierProvider<CategoryManageNotifier, AsyncValue<List<dynamic>>>(
      (ref) => CategoryManageNotifier(),
    );
