<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'image_url'
    ];

    /**
     * Get the meals for the category
     */
    public function meals()
    {
        return $this->hasMany(Meal::class);
    }
}
