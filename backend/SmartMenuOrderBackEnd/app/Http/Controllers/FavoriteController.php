<?php

namespace App\Http\Controllers;

use App\Models\Favorite;
use App\Models\Meal;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FavoriteController extends Controller
{
    // Get all favorites for the authenticated user
    public function index(Request $request)
    {
        $favorites = $request->user()->favorites()->with('meal')->get();

        // Transform to return list of meals
        $meals = $favorites->map(function ($fav) {
            return $fav->meal;
        });

        return response()->json([
            'status' => 'success',
            'favorites' => $meals
        ]);
    }

    // Add a meal to favorites
    public function store(Request $request)
    {
        $request->validate([
            'meal_id' => 'required|exists:meals,id',
        ]);

        $user = $request->user();
        $mealId = $request->meal_id;

        // Check if already favorites
        $exists = Favorite::where('user_id', $user->id)
            ->where('meal_id', $mealId)
            ->exists();

        if ($exists) {
            return response()->json([
                'status' => 'success',
                'message' => 'Meal is already in favorites',
            ]);
        }

        Favorite::create([
            'user_id' => $user->id,
            'meal_id' => $mealId,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Meal added to favorites',
        ], 201);
    }

    // Remove a meal from favorites
    public function destroy(Request $request, $mealId)
    {
        $user = $request->user();

        $deleted = Favorite::where('user_id', $user->id)
            ->where('meal_id', $mealId)
            ->delete();

        if ($deleted) {
            return response()->json([
                'status' => 'success',
                'message' => 'Meal removed from favorites',
            ]);
        } else {
            return response()->json([
                'status' => 'error',
                'message' => 'Favorite not found',
            ], 404);
        }
    }
}
