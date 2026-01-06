import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/admin_order_provider.dart';
import 'package:group_project/screen/admin/meal_manage_screen.dart';
import 'package:group_project/screen/admin/category_manage_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(adminOrderProvider.notifier).fetchOrders(ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(adminOrderProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
        backgroundColor: maincolor,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminOrderProvider.notifier).fetchOrders(ref),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Incoming Orders'),
              const SizedBox(height: 15),
              _buildStatusSection(orders, 'pending', 'New Orders', Colors.red),
              _buildStatusSection(
                orders,
                'processing',
                'In Progress',
                Colors.orange,
              ),
              _buildStatusSection(
                orders,
                'completed',
                'Completed',
                Colors.green,
              ),
              _buildStatusSection(
                orders,
                'cancelled',
                'Cancelled',
                Colors.grey,
              ),
              const SizedBox(height: 30),
              _buildSectionHeader('Management'),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    'Meals',
                    Icons.restaurant,
                    Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MealManageScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Categories',
                    Icons.category,
                    Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryManageScreen(),
                      ),
                    ),
                  ),

                  _buildMenuCard(context, 'Users', Icons.people, Colors.purple),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStatusSection(
    List<AdminOrder> orders,
    String status,
    String title,
    Color color,
  ) {
    final filteredOrders = orders.where((o) => o.status == status).toList();

    return ExpansionTile(
      title: Text(
        "$title (${filteredOrders.length})",
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: filteredOrders.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No orders"),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return ListTile(
                      title: Text(
                        "${order.userName} - ${order.mealName} (x${order.quantity})",
                      ),
                      subtitle: Text("Phone: ${order.phoneNumber}"),
                      trailing: DropdownButton<String>(
                        value: order.status,
                        underline: const SizedBox(),
                        items:
                            ['pending', 'processing', 'completed', 'cancelled']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref
                                .read(adminOrderProvider.notifier)
                                .updateStatus(ref, order.id, val);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () => print('Navigating to $title CRUD'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
