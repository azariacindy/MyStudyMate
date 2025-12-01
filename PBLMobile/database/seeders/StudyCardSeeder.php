<?php

namespace Database\Seeders;

use App\Models\StudyCard;
use App\Models\User;
use Illuminate\Database\Seeder;

class StudyCardSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::first(); // Get first user

        if (!$user) {
            $this->command->info('No users found. Please create a user first.');
            return;
        }

        $studyCards = [
            [
                'user_id' => $user->id,
                'title' => 'Introduction to Laravel',
                'description' => 'Learn the basics of Laravel framework',
                'material_type' => 'text',
                'material_content' => 'Laravel is a web application framework with expressive, elegant syntax. It provides tools for routing, authentication, sessions, caching, and more.',
            ],
            [
                'user_id' => $user->id,
                'title' => 'PHP Basics',
                'description' => 'Fundamental concepts of PHP programming',
                'material_type' => 'text',
                'material_content' => 'PHP is a popular server-side scripting language. It is used for web development and can be embedded into HTML.',
            ],
            [
                'user_id' => $user->id,
                'title' => 'Database Design',
                'description' => 'Learn about database normalization and design',
                'material_type' => 'text',
                'material_content' => 'Database design is the process of organizing data according to a database model. Good database design ensures data integrity and efficiency.',
            ],
        ];

        foreach ($studyCards as $card) {
            StudyCard::create($card);
        }

        $this->command->info('Study cards seeded successfully!');
    }
}