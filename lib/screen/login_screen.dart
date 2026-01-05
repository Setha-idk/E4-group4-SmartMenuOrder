import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/consent/navigation.dart';
import 'package:group_project/providers/user_provider.dart';
import 'package:group_project/services/telegram_service.dart';
import 'package:group_project/screen/signup_screen.dart';
import 'package:group_project/screen/admin/admin_dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telegramIdController = TextEditingController();
  bool _obscurePassword = true;
  bool _showTelegramField = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _telegramIdController.dispose();
    super.dispose();
  }

  // Auto-detect role based on email
  UserRole _getRoleFromEmail(String email) {
    final lowercaseEmail = email.toLowerCase();
    if (lowercaseEmail.contains('admin')) {
      return UserRole.admin;
    }
    return UserRole.user;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Auto-detect role based on email
      final role = _getRoleFromEmail(_emailController.text);

      final success = await ref.read(userProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
            role,
            telegramId: _showTelegramField && _telegramIdController.text.isNotEmpty
                ? _telegramIdController.text
                : null,
          );

      setState(() => _isLoading = false);

      if (success && mounted) {
        final user = ref.read(userProvider);
        if (user?.role == UserRole.admin) {
           Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
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

  void _showTelegramLoginDialog() {
    final telegramIdController = TextEditingController();
    final otpController = TextEditingController();
    bool codeSent = false;
    bool dialogLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Login with Telegram'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!codeSent) ...[
                const Text('Enter your Telegram Chat ID to receive a login code.'),
                const SizedBox(height: 16),
                TextField(
                  controller: telegramIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Telegram Chat ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.telegram),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                     final url = await ref.read(userProvider.notifier).getTelegramBotUrl();
                     if (url != null) {
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                     }
                  },
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Open Bot to Start'),
                ),
              ] else ...[
                const Text('Enter the 6-digit code sent to your Telegram.'),
                const SizedBox(height: 16),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP Code',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ],
              if (dialogLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (!codeSent)
              ElevatedButton(
                onPressed: dialogLoading
                    ? null
                    : () async {
                        if (telegramIdController.text.isEmpty) return;
                        setState(() => dialogLoading = true);
                        final success = await ref
                            .read(userProvider.notifier)
                            .sendTelegramOtp(telegramIdController.text);
                        setState(() => dialogLoading = false);

                        if (success) {
                          setState(() => codeSent = true);
                        } else {
                          if (context.mounted) {
                            final error = ref.read(userProvider.notifier).errorMessage;
                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text(error ?? 'Failed to send OTP. Check ID.')),
                            );
                          }
                        }
                      },
                child: const Text('Send Code'),
              )
            else
              ElevatedButton(
                onPressed: dialogLoading
                    ? null
                    : () async {
                        if (otpController.text.isEmpty) return;
                        setState(() => dialogLoading = true);
                        final success = await ref
                            .read(userProvider.notifier)
                            .verifyTelegramLogin(
                              telegramIdController.text,
                              otpController.text,
                            );
                        setState(() => dialogLoading = false);

                        if (success && context.mounted) {
                          Navigator.pop(context); // Close dialog
                          
                           final user = ref.read(userProvider);
                           if (user?.role == UserRole.admin) {
                             Navigator.pushReplacement(
                               context,
                               MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                             );
                           } else {
                             Navigator.pushReplacement(
                               context,
                               MaterialPageRoute(builder: (context) => const Navigation()),
                             );
                           }
                        } else {
                           if (context.mounted) {
                             final error = ref.read(userProvider.notifier).errorMessage;
                             ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error ?? 'Login failed')),
                            );
                           }
                        }
                      },
                child: const Text('Login'),
              ),
          ],
        ),
      ),
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

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      // Show Telegram field for everyone
                      setState(() {
                        _showTelegramField = true;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: maincolor),
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
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: maincolor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: maincolor,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
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
                        return 'Please enter your password';
                      }
                      if (value.length < 4) {
                        return 'Password must be at least 4 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Telegram ID Field (only for admin)
                  if (_showTelegramField) ...[
                    TextFormField(
                      controller: _telegramIdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Telegram Chat ID (Optional)',
                        helperText: 'For order notifications',
                        prefixIcon: Icon(Icons.telegram, color: maincolor),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Get Your Telegram ID'),
                                content: const Text(
                                  '1. Start chat with your bot\n'
                                  '2. Send any message\n'
                                  '3. Visit: https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates\n'
                                  '4. Find "chat":{"id": YOUR_ID}\n'
                                  '5. Enter that ID here',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Got it'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: maincolor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Login with Telegram Button
                  OutlinedButton.icon(
                    onPressed: _showTelegramLoginDialog,
                    icon: const Icon(Icons.telegram, color: Colors.blue),
                    label: const Text('Login with Telegram'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
