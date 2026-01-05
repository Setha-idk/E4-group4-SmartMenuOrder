<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MealSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $meals = [
            [
                'category_id' => 1, // Pasta
                'name' => 'Spaghetti Carbonara',
                'description' => 'Classic Italian pasta with eggs, cheese, bacon, and black pepper',
                'price' => 12.99,
                'image_url' => 'https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg',
                'tags' => 'Italian, Creamy',
                'instructions' => 'Cook pasta according to package directions. In a bowl, whisk eggs, cheese, and pepper. Drain pasta and immediately mix with egg mixture. Add cooked bacon and serve.',
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'category_id' => 2, // Pizza
                'name' => 'Margherita Pizza',
                'description' => 'Traditional pizza with tomato sauce, mozzarella, and fresh basil',
                'price' => 14.99,
                'image_url' => 'https://www.themealdb.com/images/media/meals/x0lk931587671540.jpg',
                'tags' => 'Italian, Vegetarian',
                'instructions' => 'Prepare pizza dough. Spread tomato sauce, add mozzarella cheese and fresh basil. Bake at 450°F for 12-15 minutes.',
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'category_id' => 3, // Salad
                'name' => 'Caesar Salad',
                'description' => 'Crisp romaine lettuce with Caesar dressing, croutons, and parmesan',
                'price' => 9.99,
                'image_url' => 'https://www.themealdb.com/images/media/meals/n7qnkb1630444129.jpg',
                'tags' => 'Healthy, Fresh',
                'instructions' => 'Toss romaine lettuce with Caesar dressing. Add croutons and parmesan cheese. Top with grilled chicken if desired.',
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'category_id' => 4, // Burger
                'name' => 'Classic Cheeseburger',
                'description' => 'Juicy beef patty with cheese, lettuce, tomato, and special sauce',
                'price' => 11.99,
                'image_url' => 'https://www.themealdb.com/images/media/meals/k420tj1585565244.jpg',
                'tags' => 'American, Classic',
                'instructions' => 'Grill beef patty. Toast buns. Add cheese, lettuce, tomato, and condiments. Serve with fries.',
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'category_id' => 5, // Indian
                'name' => 'Chicken Tikka Masala',
                'description' => 'Tender chicken in a creamy tomato-based curry sauce',
                'price' => 15.99,
                'image_url' => 'https://www.themealdb.com/images/media/meals/wyxwsp1486979827.jpg',
                'tags' => 'Spicy, Grilled',
                'instructions' => 'Marinate chicken in yogurt and spices. Grill until cooked through. Serve with naan bread and mint chutney.',
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'category_id' => 6, // Thai
                'name' => 'Pad Thai',
                'description' => 'Stir-fried rice noodles with shrimp, eggs, and peanuts',
                'price' => 13.99,
                'image_url' => 'https://www.themealdb.com/images/media/meals/wvtzq31574776223.jpg',
                'tags' => 'Asian, Noodles',
                'instructions' => 'Stir-fry rice noodles with eggs, vegetables, and shrimp. Add tamarind sauce and peanuts.',
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'category_id' => 7, // Dessert
                'name' => 'Chocolate Lava Cake',
                'description' => 'Warm chocolate cake with a molten chocolate center',
                'price' => 7.99,
                'image_url' => 'https://www.themealdb.com/images/media/meals/xqrwyr1511638750.jpg',
                'tags' => 'Sweet, Chocolate',
                'instructions' => 'Mix flour, sugar, cocoa, eggs, and butter. Bake at 350°F for 12 minutes. Serve warm with vanilla ice cream.',
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'category_id' => 8, // Japanese
                'name' => 'California Roll',
                'description' => 'Sushi roll with crab, avocado, and cucumber',
                'price' => 10.99,
                'image_url' => 'https://www.themealdb.com/images/media/meals/g046bb1663960946.jpg',
                'tags' => 'Seafood, Fresh',
                'instructions' => 'Prepare sushi rice. Roll with nori, cucumber, avocado, and imitation crab. Slice and serve with soy sauce.',
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'category_id' => 1, // Pasta
                'name' => 'Fettuccine Alfredo',
                'description' => 'Creamy pasta with butter, cream, and parmesan cheese',
                'price' => 13.99,
                'image_url' => 'https://www.themealdb.com/images/media/meals/uquqtu1511178042.jpg',
                'tags' => 'Italian, Creamy, Vegetarian',
                'instructions' => 'Cook fettuccine. Make Alfredo sauce with butter, cream, and parmesan. Toss pasta with sauce.',
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'category_id' => 2, // Pizza
                'name' => 'Pepperoni Pizza',
                'description' => 'Classic pizza topped with pepperoni and mozzarella cheese',
                'price' => 15.99,
                'image_url' => 'https://www.themealdb.com/images/media/meals/x0lk931587671540.jpg',
                'tags' => 'Italian, Meat',
                'instructions' => 'Prepare pizza dough. Add tomato sauce, mozzarella, and pepperoni. Bake at 450°F for 12-15 minutes.',
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'category_id' => 4, // Burger
                'name' => 'Bacon Burger',
                'description' => 'Beef burger with crispy bacon, cheese, and BBQ sauce',
                'price' => 13.99,
                'image_url' => 'https://www.themealdb.com/images/media/meals/k420tj1585565244.jpg',
                'tags' => 'American, Bacon',
                'instructions' => 'Grill beef patty with bacon. Add cheese and BBQ sauce. Serve on toasted bun.',
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'category_id' => 7, // Dessert
                'name' => 'Tiramisu',
                'description' => 'Classic Italian dessert with coffee-soaked ladyfingers and mascarpone',
                'price' => 8.99,
                'image_url' => 'https://www.themealdb.com/images/media/meals/xqrwyr1511638750.jpg',
                'tags' => 'Italian, Coffee, Sweet',
                'instructions' => 'Layer coffee-soaked ladyfingers with mascarpone mixture. Dust with cocoa powder and refrigerate.',
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
        ];

        DB::table('meals')->insert($meals);
    }
}
