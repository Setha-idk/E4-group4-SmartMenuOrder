import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/providers/notification_provider.dart';
import 'package:group_project/screen/notification_screen.dart';
import 'package:group_project/consent/colors.dart';

PreferredSizeWidget appbar({String title = 'Smart Menu Order', List<Widget>? actions}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    ),
    backgroundColor: maincolor,
    elevation: 2,
    centerTitle: true,
    iconTheme: const IconThemeData(color: Colors.white),
    actions: [
      if (actions != null) ...actions,
      // Notification Icon with Badge
      Consumer(
        builder: (context, ref, child) {
          final unreadCount = ref.watch(unreadNotificationCountProvider);
          return Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          );
        },
      ),
      const SizedBox(width: 8),
    ],
  );
}
