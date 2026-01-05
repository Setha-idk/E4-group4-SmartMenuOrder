import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum for user roles, as expected by login_screen.dart
enum UserRole { admin, user, guest }

// A placeholder User model
class User {
  final String name;
  final String email;
  final UserRole role;

  User({required this.name, required this.email, required this.role});
}

// The StateNotifier for managing the user state
class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null); // Initially, no user is logged in

  String? errorMessage;

  // Placeholder login method with Phone
  Future<bool> loginWithPhone(String phoneNumber, UserRole role) async {
    // In a real app, you would implement OTP sending and verification here.
    // For now, we'll simulate a successful login if a phone number is provided.
    print('Attempting to log in with phone: $phoneNumber');
    if (phoneNumber.isNotEmpty) {
      state = User(name: 'Test User', email: '', role: role); // email is now blank
      errorMessage = null;
      return true;
    } else {
      errorMessage = 'Invalid phone number (placeholder message)';
      return false;
    }
  }

  // Login as a guest
  void loginAsGuest() {
    state = User(name: 'Guest', email: '', role: UserRole.guest);
    errorMessage = null;
  }

  // Logout the user
  void logout() {
    state = null; // Set user to null on logout
  }
}

// The StateNotifierProvider for the UI to use
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
