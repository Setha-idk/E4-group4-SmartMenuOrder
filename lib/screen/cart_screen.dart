import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/providers/cart_provider.dart';
import 'package:group_project/providers/order_provider.dart';
import 'package:group_project/providers/user_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchHistory();
  }

  void _fetchHistory() {
    final user = ref.read(userProvider);
    if (user?.token != null) {
      ref.read(orderHistoryProvider.notifier).fetchMyOrders(user!.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final history = ref.watch(orderHistoryProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Cart & History"),
        backgroundColor: maincolor,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchHistory(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cart.isNotEmpty) ...[
                const _Header(title: "Items in Cart"),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    return ListTile(
                      leading: Image.network(item.imageUrl, width: 45, errorBuilder: (c,e,s) => const Icon(Icons.fastfood)),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${item.quantity} x \$${item.price}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => ref.read(cartProvider.notifier).removeItem(item.id),
                      ),
                    );
                  },
                ),
                _buildCheckoutSection(total),
              ],
              const _Header(title: "Your Order History"),
              if (history.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No previous orders.")))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final order = history[index];
                    return ListTile(
                      title: Text(order.mealName),
                      subtitle: Text("Status: ${order.status.toUpperCase()}", 
                        style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold)),
                      trailing: order.status == 'pending'
                          ? OutlinedButton(
                              onPressed: () => _showCancelDialog(order.id),
                              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                            )
                          : null,
                    );
                  },
                ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total:"),
              Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: maincolor, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: maincolor),
              onPressed: () => _showConfirmOrderDialog(total),
              child: const Text("Confirm Order", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmOrderDialog(double total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Place Order?"),
        content: Text("Total amount will be \$${total.toStringAsFixed(2)}."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(cartProvider.notifier).placeOrder(ref);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  _fetchHistory();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order placed!")));
                }
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () async {
              final user = ref.read(userProvider);
              await ref.read(orderHistoryProvider.notifier).cancelOrder(user?.token, id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'pending') return Colors.orange;
    if (status == 'cancelled') return Colors.red;
    return Colors.green;
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );
}