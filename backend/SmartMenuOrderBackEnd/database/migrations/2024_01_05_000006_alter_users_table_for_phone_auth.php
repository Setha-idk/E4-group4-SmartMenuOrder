<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Add new columns
            $table->string('phone_number')->unique()->nullable()->after('name');
            $table->boolean('is_admin')->default(false)->after('password');

            // Drop old columns
            $table->dropUnique('users_email_unique'); // Drop the unique index on email first
            $table->dropColumn('email');
            $table->dropColumn('email_verified_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Re-add dropped columns
            $table->string('email')->unique()->nullable()->after('name');
            $table->timestamp('email_verified_at')->nullable()->after('email');

            // Drop added columns
            $table->dropColumn('phone_number');
            $table->dropColumn('is_admin');
        });
    }
};
