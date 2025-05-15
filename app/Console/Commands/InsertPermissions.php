<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Marvel\Enums\Permission as UserPermission;

class InsertPermissions extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'insert:permissions';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Insert the required permissions into the database';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Inserting permissions...');

        // Create permissions
        Permission::firstOrCreate(['name' => UserPermission::SUPER_ADMIN, 'guard_name' => 'api']);
        Permission::firstOrCreate(['name' => UserPermission::CUSTOMER, 'guard_name' => 'api']);
        Permission::firstOrCreate(['name' => UserPermission::STORE_OWNER, 'guard_name' => 'api']);
        Permission::firstOrCreate(['name' => UserPermission::STAFF, 'guard_name' => 'api']);

        // Create roles and assign permissions
        $superAdminRole = Role::firstOrCreate(['name' => 'super_admin', 'guard_name' => 'api']);
        $storeOwnerRole = Role::firstOrCreate(['name' => 'store_owner', 'guard_name' => 'api']);
        $staffRole = Role::firstOrCreate(['name' => 'staff', 'guard_name' => 'api']);
        $customerRole = Role::firstOrCreate(['name' => 'customer', 'guard_name' => 'api']);

        // Assign permissions to roles
        $superAdminRole->syncPermissions([
            UserPermission::SUPER_ADMIN,
            UserPermission::STORE_OWNER,
            UserPermission::CUSTOMER
        ]);

        $storeOwnerRole->syncPermissions([
            UserPermission::STORE_OWNER,
            UserPermission::CUSTOMER
        ]);

        $staffRole->syncPermissions([
            UserPermission::STAFF,
            UserPermission::CUSTOMER
        ]);

        $customerRole->syncPermissions([
            UserPermission::CUSTOMER
        ]);

        $this->info('Permissions and roles have been created successfully!');
    }
}
