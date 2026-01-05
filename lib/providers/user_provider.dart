import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

enum UserRole { admin, user, guest }

class User {
  final String username;
  final String phoneNumber;
  final UserRole role;
  final bool isAdmin; // Added explicit boolean

  User({
    required this.username,
    required this.phoneNumber,
    required this.role,
    required this.isAdmin,
  });
}

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  String? errorMessage;

  // Aligning with the API URL used in your get_provider.dart
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

      // Inside login method in user_provider.dart
      if (response.statusCode == 200) {
        final data = response.data;
        final String token = data['access_token'];
        final userData = data['user'];

        // Add the token to Dio headers for future requests
        _dio.options.headers['Authorization'] = 'Bearer $token';

        final bool adminStatus =
            userData['is_admin'] == 1 || userData['is_admin'] == true;

        state = User(
          username: userData['name'],
          phoneNumber: userData['phone_number'],
          role: adminStatus ? UserRole.admin : UserRole.user,
          isAdmin: adminStatus,
        );
        return true;
      }
      errorMessage = response.data['message'] ?? 'Login failed';
      return false;
    } on DioException catch (e) {
      errorMessage = e.response?.data['message'] ?? 'Connection error';
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

      if (response.statusCode == 204 || response.statusCode == 201) {
        // Registered users are non-admins by default
        state = User(
          username: name,
          phoneNumber: phoneNumber,
          role: UserRole.user,
          isAdmin: false,
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      errorMessage = e.response?.data['message'] ?? 'Registration failed';
      return false;
    }
  }

  void loginAsGuest() {
    state = User(
      username: 'Guest',
      phoneNumber: 'N/A',
      role: UserRole.guest,
      isAdmin: false,
    );
  }

  void logout() {
    state = null;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
