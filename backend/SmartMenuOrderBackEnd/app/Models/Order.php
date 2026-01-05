<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'meal_id',
        'meal_name',
        'user_name',
        'phone_number',
        'quantity',
        'total_price',
        'status',
    ];

    /**
     * Get the user who placed the order.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the meal that was ordered.
     */
    public function meal()
    {
        return $this->belongsTo(Meal::class);
    }
}