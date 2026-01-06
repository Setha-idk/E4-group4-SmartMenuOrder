<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    // Get user's order history
    public function index(Request $request)
    {
        $query = Order::with('items.meal')->latest();

        // If user is Admin, show ALL orders
        if ($request->user()->role !== 'admin') {
            $query->where('user_id', $request->user()->id);
        }

        $orders = $query->get();

        return response()->json([
            'orders' => $orders
        ]);
    }

    // Place a new order
    public function store(Request $request)
    {
        $request->validate([
            'total_amount' => 'required|numeric',
            'items' => 'required|array|min:1',
            'items.*.meal_id' => 'required|exists:meals,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.price' => 'required|numeric',
        ]);

        try {
            DB::beginTransaction();

            // Create Order
            $order = $request->user()->orders()->create([
                'order_number' => '#ORD-' . strtoupper(uniqid()),
                'total_amount' => $request->total_amount,
                'status' => 'Pending',
            ]);

            // Create Order Items
            foreach ($request->items as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'meal_id' => $item['meal_id'],
                    'quantity' => $item['quantity'],
                    'price' => $item['price'],
                ]);
            }

            DB::commit();

            // Send Telegram Notification
            try {
                // Fetch credentials from environment variables
                $adminChatId = env('TELEGRAM_ADMIN_CHAT_ID');
                $botToken = env('TELEGRAM_BOT_TOKEN');

                if (!$botToken) {
                    \Illuminate\Support\Facades\Log::warning('TELEGRAM_BOT_TOKEN not configured.');
                } else {
                    // Load items to get product names
                    $order->load('items.meal');
                    $productList = $order->items->map(function ($item) {
                        $name = $item->meal ? $item->meal->meal : 'Unknown Product';
                        return "   • {$name} (x{$item->quantity})";
                    })->implode("\n");

                    $message = "🔔 <b>New Order Received!</b>\n" .
                        "🆔 <b>Order:</b> {$order->order_number}\n" .
                        "📦 <b>Products:</b>\n{$productList}\n" .
                        "👤 <b>Customer:</b> {$request->user()->name}\n" .
                        "💰 <b>Total:</b> \${$request->total_amount}";

                    // Collect all Admin IDs: from ENV + DB
                    $adminIds = [];
                    if ($envId = env('TELEGRAM_ADMIN_CHAT_ID')) {
                        $adminIds[] = $envId;
                    }

                    // Fetch admins from DB who have a telegram_id
                    $dbAdmins = User::where('role', 'admin')->whereNotNull('telegram_id')->pluck('telegram_id')->toArray();
                    $adminIds = array_unique(array_merge($adminIds, $dbAdmins));

                    if (empty($adminIds)) {
                        \Illuminate\Support\Facades\Log::info('No admin Telegram IDs found to notify.');
                    }

                    foreach ($adminIds as $chatId) {
                        $url = "https://api.telegram.org/bot{$botToken}/sendMessage";
                        $data = [
                            'chat_id' => $chatId,
                            'text' => $message,
                            'parse_mode' => 'HTML'
                        ];

                        $ch = curl_init();
                        curl_setopt($ch, CURLOPT_URL, $url);
                        curl_setopt($ch, CURLOPT_POST, true);
                        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
                        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                        curl_exec($ch);
                        curl_close($ch);
                    }
                }
            } catch (\Exception $e) {
                // Log error but don't fail the order
                \Illuminate\Support\Facades\Log::error('Telegram Error: ' . $e->getMessage());
            }

            return response()->json([
                'message' => 'Order placed successfully',
                'order' => $order->load('items.meal')
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Order failed', 'error' => $e->getMessage()], 500);
        }
    }

    // Update Order Status
    public function update(Request $request, $id)
    {
        // Admin check
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'status' => 'required|in:Pending,Processing,Completed,Cancelled'
        ]);

        $order = Order::findOrFail($id);
        $order->status = $request->status;
        $order->save();

        // Send In-App Notification
        \App\Models\Notification::create([
            'user_id' => $order->user_id,
            'order_id' => $order->id,
            'title' => 'Order Update',
            'message' => "Your Order {$order->order_number} is now {$request->status}",
            'is_read' => false
        ]);

        return response()->json([
            'message' => 'Order status updated',
            'order' => $order
        ]);
    }
}
