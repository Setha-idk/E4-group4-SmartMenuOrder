import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

enum UserRole { admin, user, guest }

class User {
  final int id;
  final String username;
  final String phoneNumber;
  final UserRole role;
  final String? token;

  User({
    required this.id,
    required this.username,
    required this.phoneNumber,
    required this.role,
    this.token,
  });
}

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  String? errorMessage;
  Map<String, dynamic>? fieldErrors;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<bool> login(String phoneNumber, String password) async {
    try {
      errorMessage = null;
      final response = await _dio.post(
        '/login',
        data: {'phone_number': phoneNumber, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final String token = data['token'] ?? data['access_token'];
        final userData = data['user'];

        // Add the token to Dio headers for future requests within this notifier
        _dio.options.headers['Authorization'] = 'Bearer $token';

        final bool isAdmin =
            userData['is_admin'] == 1 || userData['is_admin'] == true;

        state = User(
          id: userData['id'],
          username: userData['name'],
          phoneNumber: userData['phone_number'] ?? userData['phone'] ?? 'N/A',
          role: isAdmin ? UserRole.admin : UserRole.user,
          token: token,
        );
        return true;
      }
      errorMessage = response.data['message'] ?? 'Login failed';
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        fieldErrors = e.response?.data['errors'];
        final errors = e.response?.data['errors'];
        if (errors != null && errors is Map) {
          errorMessage = errors.values.first[0].toString();
        } else {
          errorMessage = e.response?.data['message'] ?? 'Validation error';
        }
      } else {
        errorMessage = e.response?.data['message'] ?? 'Connection error';
      }
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      errorMessage = null;
      final response = await _dio.post(
        '/register',
        data: {
          'name': name,
          'phone_number': phoneNumber,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Handle registration response to auto-login if token is provided
        if (response.data['token'] != null) {
          final data = response.data;
          state = User(
            id: data['user']['id'],
            username: name,
            phoneNumber: phoneNumber,
            role: UserRole.user,
            token: data['token'],
          );
        } else {
          loginAsGuest(); // Or leave as null
        }
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        fieldErrors = e.response?.data['errors'];
        final errors = e.response?.data['errors'];
        if (errors != null && errors is Map) {
          errorMessage = errors.values.first[0].toString();
        } else {
          errorMessage = e.response?.data['message'] ?? 'Validation error';
        }
      } else {
        errorMessage = e.response?.data['message'] ?? 'Registration failed';
      }
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? password,
  }) async {
    try {
      errorMessage = null;
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (password != null && password.isNotEmpty) data['password'] = password;

      final response = await _dio.put('/user/update', data: data);

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        state = User(
          id: userData['id'],
          username: userData['name'],
          phoneNumber: userData['phone_number'],
          role: state!.role,
          token: state!.token,
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        fieldErrors = e.response?.data['errors'];
        final errors = e.response?.data['errors'];
        if (errors != null && errors is Map) {
          errorMessage = errors.values.first[0].toString();
        } else {
          errorMessage = e.response?.data['message'] ?? 'Validation error';
        }
      } else {
        errorMessage = e.response?.data['message'] ?? 'Update failed';
      }
      return false;
    }
  }

  void loginAsGuest() {
    state = User(
      id: 0,
      username: 'Guest',
      phoneNumber: 'N/A',
      role: UserRole.guest,
      token: null,
    );
  }

  void logout() {
    _dio.options.headers.remove('Authorization');
    state = null;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
