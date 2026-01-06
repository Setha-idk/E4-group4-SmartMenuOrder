import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryManageNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  CategoryManageNotifier() : super(const AsyncValue.loading());

  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));

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
        print('Dio Error: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
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
