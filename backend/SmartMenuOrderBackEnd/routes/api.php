<?php

use App\Http\Controllers\Auth\RegisteredUserController;
use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\MealController;
use App\Http\Controllers\CategoryController;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\UserController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/admin/orders', [OrderController::class, 'index']); // For Admin
    // Status update route
    Route::patch('/orders/{order}/status', [OrderController::class, 'updateStatus']);
    Route::post('/orders/batch', [OrderController::class, 'batchStore']);

    Route::delete('/orders/{order}/cancel', [OrderController::class, 'cancel']);

    Route::apiResource('meals', MealController::class)->except(['index']);
    Route::apiResource('categories', CategoryController::class)->except(['index']);
    Route::apiResource('users', UserController::class);
});
// Public Routes
Route::post('/register', [RegisteredUserController::class, 'store']);
Route::post('/login', [AuthenticatedSessionController::class, 'store']);

// Data Routes
Route::get('/meals', [MealController::class, 'index']);
Route::get('/categories', [CategoryController::class, 'index']);


// Protected Routes
Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    Route::put('/user/update', [UserController::class, 'updateProfile']);

    Route::post('/logout', [AuthenticatedSessionController::class, 'destroy']);
});