<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth; // Important
use Illuminate\Support\Facades\Log;  // For debugging

class OrderController extends Controller
{
    public function index()
    {
        $user = Auth::user();

        if ($user->is_admin) {
            // Admins see every order in the system
            $orders = Order::orderBy('created_at', 'desc')->get();
        } else {
            // Regular users only see their own orders
            $orders = Order::where('user_id', $user->id)
                ->orderBy('created_at', 'desc')
                ->get();
        }

        return response()->json($orders, 200);
    }
    public function batchStore(Request $request)
    {
        try {
            $validated = $request->validate([
                'user_name' => 'required|string',
                'phone_number' => 'required|string',
                'items' => 'required|array',
            ]);

            $user = Auth::user();

            // Log for debugging - Check storage/logs/laravel.log
            Log::info('Order attempt by: ' . $validated['user_name']);

            foreach ($request->items as $item) {
                Order::create([
                    'user_id' => Auth::id() ?? 1, // Default to 1 or make the column nullable in migration
                    'meal_id' => $item['meal_id'],
                    'meal_name' => $item['meal_name'],
                    'user_name' => $request->user_name,
                    'phone_number' => $request->phone_number,
                    'quantity' => $item['quantity'],
                    'total_price' => $item['price'] * $item['quantity'],
                    'status' => 'pending',
                ]);
            }

            return response()->json(['message' => 'Success'], 201);
        } catch (\Exception $e) {
            Log::error('Order Error: ' . $e->getMessage());
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
    public function updateStatus(Request $request, Order $order)
    {
        $validated = $request->validate([
            'status' => 'required|in:pending,processing,completed,cancelled',
        ]);

        $order->update(['status' => $validated['status']]);

        return response()->json(['message' => 'Status updated', 'order' => $order], 200);
    }

    public function cancel(Order $order)
    {
        // Authorization check
        if ($order->user_id !== Auth::id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        // Only allow cancellation if the order hasn't been processed yet
        if ($order->status !== 'pending') {
            return response()->json(['error' => 'Order cannot be cancelled in current status'], 400);
        }

        $order->update(['status' => 'cancelled']);
        return response()->json(['message' => 'Order cancelled successfully'], 200);
    }
}
