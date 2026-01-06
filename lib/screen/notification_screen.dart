import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/notification_provider.dart';
import 'package:group_project/providers/order_provider.dart';
import 'package:group_project/screen/order_detail_sheet.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: maincolor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                   const SizedBox(height: 16),
                   Text('No notifications', style: TextStyle(color: font.withOpacity(0.6))),
                   TextButton(onPressed: () => ref.read(notificationProvider.notifier).fetchNotifications(), child: const Text('Refresh'))
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(notificationProvider.notifier).fetchNotifications(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                    key: Key(notification.id.toString()),
                    onDismissed: (_) {
                        // Mark as read or delete? For now just hide from UI logic if implemented
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: notification.isRead ? Colors.white : Colors.blue.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: maincolor.withOpacity(0.1),
                          child: Icon(Icons.notifications, color: maincolor, size: 20),
                        ),
                        title: Text(
                          notification.title, 
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 16
                          )
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             const SizedBox(height: 4),
                             Text(notification.message),
                             const SizedBox(height: 6),
                             Text(
                               DateFormat('MMM dd, hh:mm a').format(notification.createdAt),
                               style: TextStyle(fontSize: 12, color: Colors.grey.shade600)
                             ),
                          ],
                        ),
                        onTap: () async {
                           if (!notification.isRead) {
                             ref.read(notificationProvider.notifier).markAsRead(notification.id);
                           }

                           if (notification.orderId != null) {
                             // Always fetch fresh orders to ensure we have the latest status
                             await ref.read(orderProvider.notifier).fetchOrders();

                             // Try to find the order in the updated list
                             var order = ref.read(orderProvider).firstWhere(
                               (o) => o.id == notification.orderId,
                               orElse: () => Order(id: -1, orderNumber: '', totalAmount: 0, status: '', createdAt: '', items: []),
                             );

                             // If found, show details
                             if (order.id != -1 && context.mounted) {
                               OrderDetailSheet.show(context, order);
                             }
                           } else {
                              // Show generic notification detail
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(notification.title),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(notification.message),
                                        const SizedBox(height: 16),
                                        Text(
                                          DateFormat('MMM dd, yyyy hh:mm a').format(notification.createdAt),
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                           }
                        },
                      ),
                    )
                );
              },
              ),
            ),
    );
  }
}
