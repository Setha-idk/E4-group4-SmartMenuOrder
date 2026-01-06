import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/order_provider.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {

  @override
  void initState() {
    super.initState();
    // Fetch orders on init to ensure we have the latest list (including other users' orders for Admin)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).fetchOrders();
    });
  }

  String _formatDate(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('MMM dd, yyyy hh:mm a').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _showStatusDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Update Status: ${order.orderNumber}'),
        children: ['Pending', 'Processing', 'Completed', 'Cancelled'].map((status) {
          return SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context);
              // Call provider to update
              final success = await ref.read(orderProvider.notifier).updateOrderStatus(order.id, status);
              if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Status updated to $status' : 'Failed to update status')),
                  );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(status, style: TextStyle(
                  color: status == order.status ? maincolor : Colors.black,
                  fontWeight: status == order.status ? FontWeight.bold : FontWeight.normal
              )),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    // isLoading removed as it was unused and causing lint

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('All Orders', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: maincolor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
               ref.read(orderProvider.notifier).fetchOrders();
            },
          )
        ],
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                   const SizedBox(height: 16),
                   Text('No orders found', style: TextStyle(color: font.withOpacity(0.6))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final items = order.items;
                final totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity);
                
                // Assuming Order model has 'user' or 'customer_name' field if backend sends it.
                // Our current Order model in order_provider.dart might need update to incude user info.
                // Checking backend: Order::with('items.meal').latest();
                // We should add ->with('user') in backend OrderController@index to see customer name.
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(16),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () => _showStatusDialog(context, order),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getStatusColor(order.status)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    order.status,
                                    style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.edit, size: 12, color: _getStatusColor(order.status)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                         // Placeholder for customer name if not available yet
                        Row(children: [
                            const Icon(Icons.person, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            const Text('Customer ID: ', style: TextStyle(color: Colors.grey)), // We might need to add userId to Order model
                            // Text(order.userId.toString()), 
                        ]),
                        const SizedBox(height: 4),
                        Text('${_formatDate(order.createdAt)} • $totalItems Items'),
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(color: maincolor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    children: [
                      Divider(color: Colors.grey.shade200),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, itemIndex) {
                          final item = items[itemIndex];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                item.mealImage,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_,__,___) => Container(width: 40, height: 40, color: Colors.grey.shade200),
                              ),
                            ),
                            title: Text(item.mealName),
                            subtitle: Text('${item.quantity} x \$${item.price}'),
                            trailing: Text('\$${(item.quantity * item.price).toStringAsFixed(2)}'),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
