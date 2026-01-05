import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/user_provider.dart';
import 'package:group_project/screen/login_screen.dart';
// Assuming there will be an admin dashboard screen
import 'package:group_project/screen/admin/admin_dashboard_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: maincolor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: user == null
            ? _buildNotLoggedIn(context)
            : _buildLoggedIn(context, user, userNotifier),
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'You are not logged in',
          style: TextStyle(fontSize: 20, color: font),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: maincolor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Login / Register'),
        ),
      ],
    );
  }

  Widget _buildLoggedIn(BuildContext context, User user, UserNotifier userNotifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          user.username,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: font),
        ),
        const SizedBox(height: 10),
        Text(
          user.phoneNumber,
          style: TextStyle(fontSize: 18, color: font.withOpacity(0.7)),
        ),
        const SizedBox(height: 20),
        if (user.role == UserRole.admin)
          ElevatedButton(
            onPressed: () {
              //Navigate to admin dashboard
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              );
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Admin Dashboard functionality coming soon!')),
              // );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Go to Admin Dashboard'),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            userNotifier.logout();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged out successfully!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
