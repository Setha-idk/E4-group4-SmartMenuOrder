import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/providers/user_provider.dart';

class MealManageNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  MealManageNotifier() : super(const AsyncValue.loading());

  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));

  Future<void> fetchMeals() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/meals');
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveMeal(
    Map<String, dynamic> data, {
    int? id,
    required String token,
  }) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      if (id == null) {
        await _dio.post('/meals', data: data, options: options);
      } else {
        await _dio.put('/meals/$id', data: data, options: options);
      }
      fetchMeals();
      return true;
    } catch (e) {
      if (e is DioException) {
        print('Dio Error: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
      }
      print('Error saving meal: $e');
      return false;
    }
  }

  Future<void> deleteMeal(int id, String token) async {
    try {
      await _dio.delete(
        '/meals/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      fetchMeals();
    } catch (e) {
      print(e);
    }
  }
}

final mealManageProvider =
    StateNotifierProvider<MealManageNotifier, AsyncValue<List<dynamic>>>(
      (ref) => MealManageNotifier(),
    );
