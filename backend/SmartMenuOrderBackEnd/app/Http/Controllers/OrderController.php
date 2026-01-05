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
}
