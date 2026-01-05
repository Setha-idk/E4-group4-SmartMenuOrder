<?php

namespace Database\Seeders;

use App\Models\Tag;
use Illuminate\Database\Seeder;

class TagSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $tags = [
            'Italian',
            'Creamy',
            'Healthy',
            'Fresh',
            'American',
            'Classic',
        ];

        foreach ($tags as $tagName) {
            Tag::firstOrCreate(['name' => $tagName]);
        }
    }
}