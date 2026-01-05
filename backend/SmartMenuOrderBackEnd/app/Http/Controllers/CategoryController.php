<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    /**
     * Get all categories
     */
    public function index()
    {
        $categories = Category::all()->map(function ($category) {
            return [
                'id' => $category->id,
                'category' => $category->name,
                'description' => $category->description,
                'image_url' => $category->image_url
            ];
        });

        return response()->json($categories);
    }
}
