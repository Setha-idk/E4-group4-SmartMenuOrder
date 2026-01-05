import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/appbar.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/cart_provider.dart';
import 'package:group_project/providers/user_provider.dart'; // 1. Import User Provider
import 'package:group_project/screen/login_screen.dart'; // 2. Import Login Screen

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: appbar(),
      body: cart.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        leading: Image.network(item.imageUrl, width: 50),
                        title: Text(item.name),
                        subtitle: Text("${item.quantity} x \$${item.price}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => ref
                              .read(cartProvider.notifier)
                              .removeItem(item.id),
                        ),
                      );
                    },
                  ),
                ),
                _buildCartSummary(context, ref, total),
              ],
            ),
    );
  }

  Widget _buildCartSummary(BuildContext context, WidgetRef ref, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: maincolor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showCheckoutDialog(context, ref, total),
              style: ElevatedButton.styleFrom(
                backgroundColor: maincolor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, WidgetRef ref, double total) {
    final user = ref.read(userProvider);

    // 1. Force Login Check
    if (user == null || user.role == UserRole.guest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login required to place order')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Text('Total Amount: \$${total.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 2. Call the ACTUAL API method in the provider
              final success = await ref
                  .read(cartProvider.notifier)
                  .placeOrder(ref);

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order placed successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to connect to server.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }
}
