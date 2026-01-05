<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            
            // Relational Links
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('meal_id')->constrained()->onDelete('cascade');
            
            // Required Snapshot Fields
            $table->string('meal_name'); // Name of the meal at time of order
            $table->string('user_name'); // Name of the person who ordered
            $table->string('phone_number'); // Phone number used for the order
            
            // Additional helpful fields for a restaurant app
            $table->integer('quantity')->default(1);
            $table->decimal('total_price', 8, 2);
            $table->enum('status', ['pending', 'processing', 'completed', 'cancelled'])->default('pending');
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};