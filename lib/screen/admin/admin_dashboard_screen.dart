import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/user_provider.dart';
import 'package:group_project/screen/login_screen.dart';
import 'package:group_project/screen/admin/admin_product_screen.dart';
import 'package:group_project/screen/admin/admin_orders_screen.dart';
import 'package:group_project/screen/admin/admin_users_screen.dart';
import 'package:group_project/consent/navigation.dart';
import 'package:group_project/screen/notification_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: maincolor,
        centerTitle: true,
        actions: [
            IconButton(
                onPressed: () {
                    // Logout logic
                    ref.read(userProvider.notifier).logout();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                    );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, size: 30, color: maincolor),
                ),
                const SizedBox(width: 16),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text('Welcome Admin,', style: TextStyle(color: font.withOpacity(0.6), fontSize: 14)),
                        Text(user?.name ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                )
              ],
            ),
            const SizedBox(height: 32),
            const Text('Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                    _buildDashboardCard(
                        context,
                        icon: Icons.fastfood,
                        title: 'Products',
                        subtitle: 'Manage Meals',
                        color: Colors.orange,
                        onTap: () {
                            // Navigate to Product Management
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProductScreen()));
                        }
                    ),
                    _buildDashboardCard(
                        context,
                        icon: Icons.receipt_long,
                        title: 'Orders',
                        subtitle: 'View All Orders',
                        color: Colors.green,
                        onTap: () {
                            // Navigate to Admin Orders
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOrdersScreen()));
                        }
                    ),
                    _buildDashboardCard(
                        context,
                        icon: Icons.people,
                        title: 'Customers',
                        subtitle: 'View Users',
                        color: Colors.blue,
                        onTap: () {
                            // Navigate to User List
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminUsersScreen()));
                        }
                    ),
                    _buildDashboardCard(
                        context,
                        icon: Icons.notifications,
                        title: 'Notifications',
                        subtitle: 'View Alerts',
                        color: Colors.purple,
                        onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                        }
                    ),

                    _buildDashboardCard(
                        context,
                        icon: Icons.store_mall_directory,
                        title: 'Customer View',
                        subtitle: 'Browse App',
                        color: Colors.teal,
                        onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const Navigation()));
                        }
                    ),
                ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle
                        ),
                        child: Icon(icon, color: color, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: font.withOpacity(0.5), fontSize: 12)),
                ],
            ),
        ),
    );
  }
}
