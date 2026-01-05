<?php

namespace App\Http\Controllers;

use App\Models\Meal;
use Illuminate\Http\Request;

class MealController extends Controller
{
    /**
     * Get all meals with category information
     */
    public function index()
    {
        $meals = Meal::with('category')
            ->where('is_available', true)
            ->get()
            ->map(function ($meal) {
                return [
                    'id' => $meal->id,
                    'meal' => $meal->name,
                    'category' => $meal->category->name,
                    'category_id' => $meal->category_id,
                    'mealThumb' => $meal->image_url,
                    'price' => $meal->price,
                    'tags' => $meal->tags,
                    'instructions' => $meal->instructions,
                    'is_available' => $meal->is_available
                ];
            });

        return response()->json($meals);
    }
}
