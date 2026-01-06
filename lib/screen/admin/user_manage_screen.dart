import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/user_manage_provider.dart';
import 'package:group_project/providers/user_provider.dart';

class UserManageScreen extends ConsumerStatefulWidget {
  const UserManageScreen({super.key});

  @override
  ConsumerState<UserManageScreen> createState() => _UserManageScreenState();
}

class _UserManageScreenState extends ConsumerState<UserManageScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authState = ref.read(userProvider);
      if (authState?.token != null) {
        ref.read(userManageProvider.notifier).fetchUsers(authState!.token!);
      }
    });
  }

  void _showUserForm({Map<String, dynamic>? user}) {
    final nameController = TextEditingController(text: user?['name'] ?? '');
    final phoneController = TextEditingController(
      text: user?['phone_number'] ?? '',
    );
    final passwordController = TextEditingController();
    bool isAdmin = user?['is_admin'] == true || user?['is_admin'] == 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final notifier = ref.read(userManageProvider.notifier);

          return AlertDialog(
            title: Text(user == null ? 'Add User' : 'Edit User'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      errorText: notifier.fieldErrors?['name'] != null
                          ? notifier.fieldErrors!['name'][0]
                          : null,
                    ),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      errorText: notifier.fieldErrors?['phone_number'] != null
                          ? notifier.fieldErrors!['phone_number'][0]
                          : null,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: user == null
                          ? 'Password'
                          : 'New Password (optional)',
                      helperText: user == null
                          ? null
                          : 'Leave blank if not changing',
                      errorText: notifier.fieldErrors?['password'] != null
                          ? notifier.fieldErrors!['password'][0]
                          : null,
                    ),
                    obscureText: true,
                  ),
                  SwitchListTile(
                    title: const Text('Admin Role'),
                    value: isAdmin,
                    onChanged: (val) => setDialogState(() => isAdmin = val),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final authState = ref.read(userProvider);
                  final token = authState?.token;

                  if (token == null) return;

                  final userData = {
                    'name': nameController.text,
                    'phone_number': phoneController.text,
                    'is_admin': isAdmin,
                  };

                  if (passwordController.text.isNotEmpty) {
                    userData['password'] = passwordController.text;
                  } else if (user == null) {
                    setDialogState(() {
                      notifier.fieldErrors = {
                        'password': ['Password is required for new users'],
                      };
                    });
                    return;
                  }

                  final success = await notifier.saveUser(
                    userData,
                    id: user?['id'],
                    token: token,
                  );

                  if (success) {
                    if (mounted) Navigator.pop(context);
                  } else {
                    setDialogState(() {}); // Rebuild to show field errors
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(userManageProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: maincolor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: usersState.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final bool isAdmin =
                user['is_admin'] == true || user['is_admin'] == 1;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isAdmin
                      ? Colors.purple.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  child: Icon(
                    isAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: isAdmin ? Colors.purple : Colors.blue,
                  ),
                ),
                title: Text(user['name'] ?? 'Unnamed'),
                subtitle: Text(user['phone_number'] ?? 'No phone'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showUserForm(user: user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Don't allow deleting self?
                        final currentUserId = ref.read(userProvider)?.id;
                        if (currentUserId == user['id']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cannot delete yourself'),
                            ),
                          );
                          return;
                        }

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete User'),
                            content: const Text(
                              'Are you sure you want to delete this user?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final authState = ref.read(userProvider);
                                  if (authState?.token != null) {
                                    ref
                                        .read(userManageProvider.notifier)
                                        .deleteUser(
                                          user['id'],
                                          authState!.token!,
                                        );
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(),
        backgroundColor: maincolor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
