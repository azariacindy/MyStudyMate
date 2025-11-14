<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    /**
     * Register a new user
     */
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users,username',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6',
        ]);

        try {
            $now = now();

            // Insert ke Supabase dan ambil ID yang di-generate
            $id = DB::table('users')->insertGetId([
                'name' => $request->name,
                'username' => $request->username,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'email_verified_at' => null,
                'remember_token' => null,
                'created_at' => $now,
                'updated_at' => $now,
            ], 'id');

            return response()->json([
                'user' => [
                    'id' => (string) $id,      // Pastikan tipe string untuk Flutter
                    'name' => $request->name,
                    'username' => $request->username,
                    'email' => $request->email,
                ],
                'token' => Str::random(60)
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Registration failed.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Login with email OR username
     */
    public function login(Request $request)
    {
        $request->validate([
            'login_identifier' => 'required|string',
            'password' => 'required|string',
        ]);

        // Deteksi apakah input berupa email
        $isEmail = filter_var($request->login_identifier, FILTER_VALIDATE_EMAIL);
        $field = $isEmail ? 'email' : 'username';

        // Cari user di Supabase
        $user = DB::table('users')
            ->where($field, $request->login_identifier)
            ->first();

        // Validasi keberadaan user dan kecocokan password
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Invalid credentials.'
            ], 401);
        }

        return response()->json([
            'user' => [
                'id' => (string) $user->id,
                'name' => $user->name,
                'username' => $user->username,
                'email' => $user->email,
            ],
            'token' => Str::random(60)
        ]);
    }

    /**
     * Logout (opsional, karena token stateless)
     */
    public function logout()
    {
        return response()->json([
            'message' => 'Successfully logged out.'
        ]);
    }
}