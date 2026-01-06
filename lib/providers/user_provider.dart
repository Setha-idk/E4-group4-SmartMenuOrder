import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:group_project/providers/favorites_provider.dart';

// User roles enum
enum UserRole {
  admin,
  user,
  guest,
}

// User model
class User {
  final String name;
  final String email;
  final UserRole role;
  final String? telegramId;
  final String? token; // Added token field

  User({
    required this.name,
    required this.email,
    required this.role,
    this.telegramId,
    this.token,
  });

  String get roleDisplay {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.user:
        return 'User';
      case UserRole.guest:
        return 'Guest';
    }
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isUser => role == UserRole.user;
  bool get isGuest => role == UserRole.guest;
}

// User state notifier
class UserNotifier extends StateNotifier<User?> {
  UserNotifier(this.ref) : super(null);
  
  final Ref ref;
  
  // Use localhost which often resolves better on Windows
  static const String baseUrl = 'http://localhost:8000/api';

  // Store access token
  String? _token;
  String? get token => _token;
  
  // Store last error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Check authentication on startup
  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];
        _token = token;

        // Map backend role
        UserRole userRole = UserRole.user;
        if (userData['role'] == 'admin') {
          userRole = UserRole.admin;
        }

        state = User(
          name: userData['name'],
          email: userData['email'],
          role: userRole,
          telegramId: userData['telegram_id'],
          token: token,
        );
        
        // Sync favorites
        await ref.read(favoritesProvider.notifier).fetchFavorites();
      } else {
        // Token invalid
        await prefs.remove('auth_token');
        _token = null;
      }
    } catch (e) {
      print('Check auth error: $e');
    }
  }

  // Login with credentials
  Future<bool> login(String email, String password, UserRole role, {String? telegramId}) async {
    _errorMessage = null; // Reset error
    try {
      print('Attempting login to: $baseUrl/login');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          if (telegramId != null) 'telegram_id': telegramId,
        }),
      );
      
      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];
        _token = data['access_token']; // Store token
        
        // Save token persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        
        // Map backend role string to Enum
        UserRole userRole = UserRole.user;
        if (userData['role'] == 'admin') {
          userRole = UserRole.admin;
        }

        state = User(
          name: userData['name']?.toString() ?? 'User',
          email: userData['email']?.toString() ?? '',
          role: userRole,
          telegramId: telegramId,
          token: _token,
        );
        
        // Sync favorites
        await ref.read(favoritesProvider.notifier).fetchFavorites();
         
        return true;
      } else {
        // Check if response is HTML
        if (response.body.trim().startsWith('<')) {
          _errorMessage = 'Server error (${response.statusCode}). Please check backend URL.';
        } else {
          try {
            final data = jsonDecode(response.body);
            _errorMessage = data['message']?.toString() ?? 'Login failed.';
          } catch (e) {
             print('Error parsing login error: $e');
             _errorMessage = 'Unknown error (${response.statusCode})';
          }
        }
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      // Show actual error for debugging
      _errorMessage = 'Connection error: $e';
      return false;
    }
  }

  // Sign up
  Future<bool> signup({required String name, required String email, required String password}) async {
    _errorMessage = null; // Reset error
    try {
      print('Attempting signup to: $baseUrl/register');
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

       print('Signup Response Status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];
        if (userData == null) throw Exception('User data is null');

        _token = data['access_token']; 

        if (_token != null) {
           // Save token persistence
           final prefs = await SharedPreferences.getInstance();
           await prefs.setString('auth_token', _token!);
        }

        try {
          state = User(
            name: userData['name']?.toString() ?? 'User',
            email: userData['email']?.toString() ?? '',
            role: UserRole.user,
            telegramId: null,
            token: _token,
          );
        } catch (e) {
          rethrow;
        }
        
        // Sync favorites
        await ref.read(favoritesProvider.notifier).fetchFavorites();
        
        return true;
      } else {
        // Check if response is HTML
        if (response.body.trim().startsWith('<')) {
          _errorMessage = 'Server error (${response.statusCode})';
        } else {
          try {
            final data = jsonDecode(response.body);
             print('Signup Error Data: $data'); // Debug print
             if (data['errors'] != null) {
                // Safely extract the first error message
                final errors = data['errors'] as Map<String, dynamic>;
                if (errors.isNotEmpty) {
                  final firstError = errors.values.first;
                  if (firstError is List && firstError.isNotEmpty) {
                    _errorMessage = firstError[0].toString();
                  } else {
                    _errorMessage = firstError.toString();
                  }
                } else {
                   _errorMessage = 'Validation failed';
                }
             } else {
                _errorMessage = data['message'] ?? 'Sign up failed.';
             }
          } catch (e) {
             print('Error parsing error response: $e');
             _errorMessage = 'Unknown error (${response.statusCode})';
          }
        }
        return false;
      }
    } catch (e) {
      print('Signup error: $e');
      _errorMessage = 'Connection error: $e';
      return false;
    }
  }

  // Login as guest
  void loginAsGuest() {
    _token = null;
    state = User(
      name: 'Guest User',
      email: 'guest@smartmenu.com',
      role: UserRole.guest,
      telegramId: null,
      token: null,
    );
    ref.read(favoritesProvider.notifier).clear();
  }

  // Update user profile
  Future<bool> updateProfile({String? name, String? email}) async {
    if (state == null || _token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (email != null) 'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];

        // Update local state
        state = User(
          name: userData['name'],
          email: userData['email'],
          role: state!.role,
          telegramId: state!.telegramId,
          token: _token,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  // Send Telegram OTP
  Future<bool> sendTelegramOtp(String telegramId) async {
    _errorMessage = null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'telegram_id': telegramId}),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
         try {
           final data = jsonDecode(response.body);
           // Handle validation errors specifically
           if (data['errors'] != null && data['errors']['telegram_id'] != null) {
              _errorMessage = 'Telegram ID not found. Please log in normally and link it first.';
           } else {
              _errorMessage = data['message'] ?? 'Failed to send OTP';
           }
         } catch(e) {
           _errorMessage = 'Server error (${response.statusCode})';
         }
         return false;
      }
    } catch (e) {
      print('Send OTP error: $e');
      _errorMessage = 'Connection error: $e';
      return false;
    }
  }

  // Login with Telegram OTP
  Future<bool> verifyTelegramLogin(String telegramId, String otpCode) async {
    _errorMessage = null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'telegram_id': telegramId,
          'otp_code': otpCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];
        _token = data['access_token'];

        // Save token persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        // Map backend role
        UserRole userRole = UserRole.user;
        if (userData['role'] == 'admin') {
          userRole = UserRole.admin;
        }

        state = User(
          name: userData['name'],
          email: userData['email'],
          role: userRole,
          telegramId: userData['telegram_id'],
          token: _token,
        );

        // Sync favorites
        await ref.read(favoritesProvider.notifier).fetchFavorites();
        return true;
      } else {
        try {
          final data = jsonDecode(response.body);
          _errorMessage = data['message'] ?? 'Login failed';
        } catch (e) {
          _errorMessage = 'Invalid OTP';
        }
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    if (_token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
             'Authorization': 'Bearer $_token',
             'Accept': 'application/json',
          },
        );
      } catch (e) {
        print('Logout error: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    _token = null;
    state = null;
    ref.read(favoritesProvider.notifier).clear();
  }

  // Get Telegram Bot URL
  Future<String?> getTelegramBotUrl() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/telegram-bot'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      }
      return null;
    } catch (e) {
      print('Get Bot URL error: $e');
      return null;
    }
  }

  // Login with Telegram OTP
  Future<bool> loginWithTelegram(String email, String otp) async {
    _errorMessage = null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      print('Telegram Login Status: ${response.statusCode}');
      print('Telegram Login Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        // Set user state
        state = User(
          name: data['user']['name'],
          email: data['user']['email'],
          role: data['user']['role'] == 'admin' ? UserRole.admin : UserRole.user,
          telegramId: data['user']['telegram_id'],
          token: _token,
        );

        return true;
      } else {
        final body = jsonDecode(response.body);
        _errorMessage = body['message'] ?? 'Invalid OTP';
        return false;
      }
    } catch (e) {
      print('Telegram login error: $e');
      _errorMessage = 'Connection error';
      return false;
    }
  }
}

// User provider
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(ref);
});

// Convenience providers
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userProvider) != null;
});

final currentUserRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(userProvider)?.role;
});
