<?php

namespace App\Http\Controllers;

use App\Models\Meal;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class MealController extends Controller
{
    public function index()
    {
        return response()->json(Meal::with('category')->get());
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'category_id' => 'required|exists:categories,id',
            'description' => 'required|string',
            'price' => 'required|numeric',
            'image_url' => 'required|string',
            'instructions' => 'nullable|string',
            'is_available' => 'boolean'
        ]);

        $meal = Meal::create($validated);
        return response()->json($meal, 201);
    }

    public function update(Request $request, Meal $meal)
    {
        $validated = $request->validate([
            'name' => 'string',
            'category_id' => 'exists:categories,id',
            'description' => 'string',
            'price' => 'numeric',
            'image_url' => 'string',
            'instructions' => 'nullable|string',
            'is_available' => 'boolean'
        ]);

        $meal->update($validated);
        return response()->json($meal);
    }

    public function destroy(Meal $meal)
    {
        $meal->delete();
        return response()->json(null, 204);
    }
}