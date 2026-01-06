import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/user_provider.dart';
import 'package:group_project/screen/login_screen.dart';
// Assuming there will be an admin dashboard screen
import 'package:group_project/screen/admin/admin_dashboard_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setupControllers(User user) {
    _nameController.text = user.username;
    _phoneController.text = user.phoneNumber;
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);

    if (user != null && !_isEditing && _nameController.text.isEmpty) {
      _setupControllers(user);
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: maincolor,
        foregroundColor: Colors.white,
        actions: [
          if (user != null && user.role != UserRole.guest)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) _setupControllers(user);
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: user == null
              ? _buildNotLoggedIn(context)
              : _buildLoggedIn(context, user, userNotifier),
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 100),
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

  Widget _buildLoggedIn(
    BuildContext context,
    User user,
    UserNotifier userNotifier,
  ) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 60, color: Colors.grey),
        ),
        const SizedBox(height: 30),
        if (!_isEditing) ...[
          Text(
            user.username,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: font,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user.phoneNumber,
            style: TextStyle(fontSize: 18, color: font.withOpacity(0.7)),
          ),
          const SizedBox(height: 40),
        ] else ...[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
              errorText: userNotifier.fieldErrors?['name'] != null
                  ? userNotifier.fieldErrors!['name'][0]
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone),
              border: const OutlineInputBorder(),
              errorText: userNotifier.fieldErrors?['phone_number'] != null
                  ? userNotifier.fieldErrors!['phone_number'][0]
                  : null,
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'New Password (Optional)',
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
              errorText: userNotifier.fieldErrors?['password'] != null
                  ? userNotifier.fieldErrors!['password'][0]
                  : null,
            ),
            obscureText: true,
          ),
          const SizedBox(height: 30),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                final success = await userNotifier.updateProfile(
                  name: _nameController.text,
                  phoneNumber: _phoneController.text,
                  password: _passwordController.text,
                );
                setState(() => _isLoading = false);

                if (success) {
                  setState(() => _isEditing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        userNotifier.errorMessage ?? 'Update failed',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: maincolor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('SAVE CHANGES'),
            ),
          const SizedBox(height: 20),
        ],
        if (user.role == UserRole.admin)
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Admin Dashboard'),
          ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () {
            userNotifier.logout();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Logged out!')));
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
