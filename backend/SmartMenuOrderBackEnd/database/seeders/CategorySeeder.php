<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Pasta',
                'description' => 'Delicious Italian pasta dishes',
                'image_url' => null,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Pizza',
                'description' => 'Authentic wood-fired pizzas',
                'image_url' => null,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Salad',
                'description' => 'Fresh and healthy salads',
                'image_url' => null,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Burger',
                'description' => 'Juicy gourmet burgers',
                'image_url' => null,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Indian',
                'description' => 'Aromatic Indian cuisine',
                'image_url' => null,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Thai',
                'description' => 'Spicy and flavorful Thai dishes',
                'image_url' => null,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Dessert',
                'description' => 'Sweet treats and desserts',
                'image_url' => null,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Japanese',
                'description' => 'Traditional Japanese cuisine',
                'image_url' => null,
                'created_at' => now(),
                'updated_at' => now()
            ],
        ];

        DB::table('categories')->insert($categories);
    }
}
