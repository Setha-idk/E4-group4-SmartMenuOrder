import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/consent/navigation.dart';
import 'package:group_project/providers/user_provider.dart';
import 'package:group_project/providers/favorite_provider.dart';
import 'package:group_project/screen/signup_screen.dart';
import 'package:group_project/screen/admin/admin_dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // TODO: Implement a real role detection if needed
  UserRole _getRoleFromPhone(String phone) {
    // Placeholder logic: if phone number contains 'admin', treat as admin.
    if (phone.contains('admin')) {
      return UserRole.admin;
    }
    return UserRole.user;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final role = _getRoleFromPhone(_phoneController.text);

      final success = await ref.read(userProvider.notifier).loginWithPhone(
            _phoneController.text,
            role,
          );

      setState(() => _isLoading = false);

      if (success && mounted) {
        await ref.read(favoriteProvider.notifier).syncFavoritesOnLogin();
        
        final user = ref.read(userProvider);
        if (user?.role == UserRole.admin) {
           Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => const AdminDashboard()),
           );
        } else {
           Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => const Navigation()),
           );
        }
      } else if (mounted) {
        final error = ref.read(userProvider.notifier).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleGuestLogin() {
    ref.read(userProvider.notifier).loginAsGuest();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Navigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: maincolor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Title
                  Text(
                    'Smart Menu Order',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: maincolor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please login to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: font.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Phone Number Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone, color: maincolor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: maincolor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      // Basic validation for phone number length
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maincolor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: font.withOpacity(0.6)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: maincolor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Guest Login Button
                  OutlinedButton.icon(
                    onPressed: _handleGuestLogin,
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Continue as Guest'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: maincolor,
                      side: BorderSide(color: maincolor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
