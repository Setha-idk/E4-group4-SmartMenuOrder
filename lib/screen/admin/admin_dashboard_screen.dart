import 'package:flutter/material.dart';
import 'package:group_project/consent/colors.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
        backgroundColor: maincolor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Incoming Orders'),
            const SizedBox(height: 10),
            _buildOrderList(),
            const SizedBox(height: 30),
            _buildSectionHeader('Management'),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(context, 'Meals', Icons.restaurant, Colors.orange),
                _buildMenuCard(context, 'Categories', Icons.category, Colors.blue),
                _buildMenuCard(context, 'Tags', Icons.label, Colors.green),
                _buildMenuCard(context, 'Users', Icons.people, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildOrderList() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: 3, // Replace with actual order stream/provider
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
            title: Text('Order #102${index + 1}'),
            subtitle: const Text('2x Carbonara, 1x Coke'),
            trailing: const Text('Pending', style: TextStyle(color: Colors.red)),
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // Navigate to respective CRUD screens
        print('Navigating to $title CRUD');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
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