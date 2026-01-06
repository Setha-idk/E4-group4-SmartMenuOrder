<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    // Register a new user
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'user', // Default role
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'User created successfully',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user,
        ], 201);
    }

    // Login user
    public function login(Request $request)
    {
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid login details'
            ], 401);
        }

        $user = User::where('email', $request['email'])->firstOrFail();

        // Update telegram_id if provided (especially for admins)
        if ($request->has('telegram_id') && !empty($request->telegram_id)) {
            $user->telegram_id = $request->telegram_id;
            $user->save();
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Login successful',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user,
        ]);
    }

    // Update user profile
    public function update(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $user->id,
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validator->errors()
            ], 422);
        }

        if ($request->has('name')) {
            $user->name = $request->name;
        }

        if ($request->has('email')) {
            $user->email = $request->email;
        }

        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Profile updated successfully',
            'user' => $user
        ]);
    }

    // Logout user
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logged out successfully'
        ]);
    }

    // Get current user details
    public function me(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'user' => $request->user(),
        ]);
    }
    // Send OTP via Telegram
    public function sendOtp(Request $request)
    {
        $request->validate([
            'telegram_id' => 'required|string',
        ]);

        // Find or Create User
        $user = User::firstOrCreate(
            ['telegram_id' => $request->telegram_id],
            [
                'name' => 'Telegram User',
                'email' => 'tg_' . $request->telegram_id . '@smartmenu.com',
                'password' => Hash::make(\Illuminate\Support\Str::random(16)),
                'role' => 'user',
            ]
        );

        // Generate 6-digit OTP
        $otp = rand(100000, 999999);
        $user->otp_code = $otp;
        $user->otp_expires_at = now()->addMinutes(5); // Valid for 5 minutes
        $user->save();

        // Send to Telegram
        $botToken = env('TELEGRAM_BOT_TOKEN');
        if (!$botToken) {
            return response()->json(['message' => 'Telegram Bot Token not configured'], 500);
        }

        $message = "🔐 <b>Your Login OTP:</b> <code>{$otp}</code>\n" .
            "<i>Valid for 5 minutes.</i>";

        $url = "https://api.telegram.org/bot{$botToken}/sendMessage";
        $data = [
            'chat_id' => $user->telegram_id,
            'text' => $message,
            'parse_mode' => 'HTML'
        ];

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        curl_close($ch);

        return response()->json(['message' => 'OTP sent to Telegram']);
    }

    // Verify OTP and Login
    public function verifyOtp(Request $request)
    {
        $request->validate([
            'telegram_id' => 'required|string',
            'otp_code' => 'required|string',
        ]);

        $user = User::where('telegram_id', $request->telegram_id)->first();

        if (!$user || $user->otp_code !== $request->otp_code) {
            return response()->json(['message' => 'Invalid OTP'], 401);
        }

        if ($user->otp_expires_at < now()) {
            return response()->json(['message' => 'OTP Expired'], 401);
        }

        // Clear OTP
        $user->otp_code = null;
        $user->otp_expires_at = null;
        $user->save();

        // Login User
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Login successful',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user,
        ]);
    }

    // Get Telegram Bot Link
    public function getBotUrl()
    {
        $token = env('TELEGRAM_BOT_TOKEN');
        if (!$token) {
            return response()->json(['url' => null]);
        }

        $url = "https://api.telegram.org/bot{$token}/getMe";

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        curl_close($ch);

        $data = json_decode($response, true);

        if (isset($data['result']['username'])) {
            return response()->json([
                'url' => "https://t.me/" . $data['result']['username'],
                'username' => $data['result']['username']
            ]);
        }

        return response()->json(['url' => null]);
    }
}
