<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Admin User
        User::create([
            'name' => 'Admin User',
            'phone_number' => '0123456789',
            'password' => Hash::make('admin123'),
            'is_admin' => true,
        ]);

        // Regular User
        User::create([
            'name' => 'Test User',
            'phone_number' => '0987654321',
            'password' => Hash::make('user123'),
            'is_admin' => false,
        ]);
    }
}