<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\MealController;
use App\Http\Controllers\CategoryController;

// Categories endpoint
Route::get('/categories', [CategoryController::class, 'index']);

// Meals endpoint
Route::get('/meals', [MealController::class, 'index']);

// Health check endpoint
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'Smart Menu Order API is running',
        'timestamp' => now()->toDateTimeString()
    ]);
});
