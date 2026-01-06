import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:group_project/providers/user_provider.dart';
import 'package:group_project/models/notification.dart';

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier(this.ref) : super([]) {
    // Start polling if user is logged in
    _startPolling();
    
    // Listen for user login/logout to fetch immediately
    ref.listen<User?>(userProvider, (previous, next) {
      if (next != null && next.token != null) {
         fetchNotifications();
      } else {
         state = []; // Clear notifications on logout
      }
    });
  }

  final Ref ref;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer?.cancel();
    // Poll every 10 seconds for better responsiveness
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchNotifications();
    });
    // Initial fetch
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final user = ref.read(userProvider);
    if (user == null || user.token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${UserNotifier.baseUrl}/notifications'),
        headers: {
          'Authorization': 'Bearer ${user.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['notifications'];
        state = list.map((json) => AppNotification.fromJson(json)).toList();
      }
    } catch (e) {
      print('Fetch notifications error: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    final user = ref.read(userProvider);
    if (user == null || user.token == null) return;

    // Optimistic update
    state = [
      for (final n in state)
        if (n.id == id)
          AppNotification(
            id: n.id,
            title: n.title,
            message: n.message,
            isRead: true, 
            createdAt: n.createdAt
          )
        else
          n
    ];

    try {
      await http.post(
        Uri.parse('${UserNotifier.baseUrl}/notifications/$id/read'),
        headers: {
          'Authorization': 'Bearer ${user.token}',
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      // print('Mark read error: $e');
    }
  }
  
  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier(ref);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).where((n) => !n.isRead).length; 
});

final notificationEnabledProvider = StateProvider<bool>((ref) => true);
