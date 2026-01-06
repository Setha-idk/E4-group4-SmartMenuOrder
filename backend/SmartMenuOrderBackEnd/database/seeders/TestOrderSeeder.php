<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Meal;

class TestOrderSeeder extends Seeder
{
    public function run(): void
    {
        $meal = Meal::first();
        if (!$meal) {
            $this->command->error('No meals found!');
            return;
        }

        $order = Order::create([
            'user_id' => 1,
            'order_number' => '#ORD-TEST-' . rand(1000, 9999),
            'total_amount' => 25.50,
            'status' => 'Pending',
        ]);

        OrderItem::create([
            'order_id' => $order->id,
            'meal_id' => $meal->id,
            'quantity' => 2,
            'price' => 12.75,
        ]);

        $this->command->info('Test Order Created: ' . $order->order_number);
    }
}
