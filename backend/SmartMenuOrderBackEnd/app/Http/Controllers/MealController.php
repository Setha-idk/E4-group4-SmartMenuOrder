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
    /**
     * Store a newly created meal in storage.
     */
    /**
     * Store a newly created meal in storage.
     */
    public function store(Request $request)
    {
        // Simple admin check
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'meal' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'image' => 'nullable|image|max:2048', // File upload
            'mealThumb' => 'nullable|url',        // Fallback or external URL
            'price' => 'required|numeric|min:0',
            'instructions' => 'nullable|string',
            'tags' => 'nullable|string',
        ]);

        $imageUrl = $validated['mealThumb'] ?? '';

        // Handle File Upload
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('meals', 'public');
            $imageUrl = asset('storage/' . $path);
        }

        $meal = Meal::create([
            'name' => $validated['meal'],
            'category_id' => $validated['category_id'],
            'image_url' => $imageUrl,
            'price' => $validated['price'],
            'instructions' => $validated['instructions'] ?? '',
            'tags' => $validated['tags'] ?? '',
            'is_available' => true,
        ]);

        return response()->json(['message' => 'Meal created successfully', 'meal' => $meal], 201);
    }

    /**
     * Update the specified meal in storage.
     */
    public function update(Request $request, $id)
    {
        // Simple admin check
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $meal = Meal::findOrFail($id);

        $validated = $request->validate([
            'meal' => 'sometimes|string|max:255',
            'category_id' => 'sometimes|exists:categories,id',
            'image' => 'nullable|image|max:2048',
            'mealThumb' => 'nullable|url',
            'price' => 'sometimes|numeric|min:0',
            'instructions' => 'nullable|string',
            'tags' => 'nullable|string',
            'is_available' => 'boolean',
        ]);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('meals', 'public');
            $meal->image_url = asset('storage/' . $path);
        } elseif (isset($validated['mealThumb'])) {
            $meal->image_url = $validated['mealThumb'];
        }

        if (isset($validated['meal']))
            $meal->name = $validated['meal'];
        if (isset($validated['category_id']))
            $meal->category_id = $validated['category_id'];
        if (isset($validated['price']))
            $meal->price = $validated['price'];
        if (isset($validated['instructions']))
            $meal->instructions = $validated['instructions'];
        if (isset($validated['tags']))
            $meal->tags = $validated['tags'];
        if (isset($validated['is_available']))
            $meal->is_available = $validated['is_available'];

        $meal->save();

        return response()->json(['message' => 'Meal updated successfully', 'meal' => $meal]);
    }

    /**
     * Remove the specified meal from storage.
     */
    public function destroy(Request $request, $id)
    {
        // Simple admin check
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $meal = Meal::findOrFail($id);
        $meal->delete();

        return response()->json(['message' => 'Meal deleted successfully']);
    }
}
