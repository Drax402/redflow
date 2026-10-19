<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::disableForeignKeyConstraints();
        Schema::dropIfExists('blood_transfers');
        Schema::dropIfExists('blood_bags');
        Schema::dropIfExists('storage_units');
        Schema::enableForeignKeyConstraints();

        if (Schema::hasTable('app_notifications') && Schema::hasColumn('app_notifications', 'category')) {
            DB::table('app_notifications')->where('category', 'blood_expiry')->delete();
        }

        if (!Schema::hasTable('users') || !Schema::hasColumn('users', 'role')) {
            return;
        }

        DB::table('users')->where('role', 'Blood Bank MedTech')->update(['role' => 'Staff']);

        $driver = DB::connection()->getDriverName();
        if (in_array($driver, ['mysql', 'mariadb'], true)) {
            DB::statement("ALTER TABLE `users` MODIFY `role` ENUM('Admin','Staff') NOT NULL DEFAULT 'Staff'");
        }
    }

    public function down(): void
    {
    }
};
