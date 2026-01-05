import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// Enum for user roles, as expected by login_screen.dart
enum UserRole { admin, user, guest }

// A placeholder User model
class User {
  final String username;
  final String phoneNumber;
  final UserRole role;

  User({required this.username, required this.phoneNumber, required this.role});

  bool get isAdmin => role == UserRole.admin;
}

// The StateNotifier for managing the user state
class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  String? errorMessage;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://your-api-url.com/api', // Replace with your backend URL
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  // Handle registration logic matching RegisteredUserController.php
  Future<bool> register({
    required String name,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      errorMessage = null;
      final response = await _dio.post('/register', data: {
        'name': name,
        'phone_number': phoneNumber,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      if (response.statusCode == 204 || response.statusCode == 201) {
        // Automatically log in the user locally after successful registration
        state = User(
          username: name,
          phoneNumber: phoneNumber,
          role: UserRole.user,
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      errorMessage = e.response?.data['message'] ?? 'Registration failed';
      return false;
    } catch (e) {
      errorMessage = 'An unexpected error occurred';
      return false;
    }
  }

  // Placeholder login method with Phone
  Future<bool> loginWithPhone(String phoneNumber, UserRole role) async {
    print('Attempting to log in with phone: $phoneNumber');
    if (phoneNumber.isNotEmpty) {
      state = User(username: 'Test User', phoneNumber: phoneNumber, role: role);
      errorMessage = null;
      return true;
    } else {
      errorMessage = 'Invalid phone number (placeholder message)';
      return false;
    }
  }

  // Login as a guest
  void loginAsGuest() {
    state = User(username: 'Guest', phoneNumber: 'N/A', role: UserRole.guest);
    errorMessage = null;
  }

  // Logout the user
  void logout() {
    state = null;
  }
}

// The StateNotifierProvider for the UI to use
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});