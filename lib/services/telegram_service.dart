import 'dart:convert';
import 'package:http/http.dart' as http;

class TelegramService {
  // Your Telegram Bot Token
  static const String botToken = '8551590351:AAFXSOu8kapoSzgTiDidKxPpcNcJm5bNNio';
  static const String baseUrl = 'https://api.telegram.org/bot$botToken';

  /// Send a text message to a Telegram chat
  static Future<bool> sendMessage(String chatId, String message) async {
    try {
      final url = Uri.parse('$baseUrl/sendMessage');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'HTML', // Enable HTML formatting
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Telegram message sent successfully');
        return true;
      } else {
        print('❌ Failed to send Telegram message: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending Telegram message: $e');
      return false;
    }
  }

  /// Send order notification to admin
  static Future<bool> sendOrderNotification({
    required String adminChatId,
    required String customerName,
    required String customerEmail,
    required List<Map<String, dynamic>> items,
    required double total,
  }) async {
    // Format the order message
    final buffer = StringBuffer();
    buffer.writeln('🔔 <b>New Order Received!</b>');
    buffer.writeln('');
    buffer.writeln('👤 <b>Customer:</b> $customerName');
    buffer.writeln('📧 <b>Email:</b> $customerEmail');
    buffer.writeln('');
    buffer.writeln('📋 <b>Order Items:</b>');
    
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final name = item['name'] ?? 'Unknown';
      final quantity = item['quantity'] ?? 0;
      final price = item['price'] ?? 0.0;
      final itemTotal = quantity * price;
      
      buffer.writeln('${i + 1}. $name x$quantity = \$${itemTotal.toStringAsFixed(2)}');
    }
    
    buffer.writeln('');
    buffer.writeln('💰 <b>Total:</b> \$${total.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('⏰ ${DateTime.now().toString().substring(0, 19)}');

    return await sendMessage(adminChatId, buffer.toString());
  }

  /// Test connection by sending a test message
  static Future<bool> testConnection(String chatId) async {
    return await sendMessage(
      chatId,
      '✅ Telegram bot connected successfully!\n\nYou will receive order notifications here.',
    );
  }
}
