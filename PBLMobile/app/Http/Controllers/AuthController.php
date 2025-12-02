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

        // Convert to User model for Sanctum
        $userModel = \App\Models\User::find($user->id);
        
        // Create Sanctum token
        $token = $userModel->createToken('mobile-app')->plainTextToken;

        return response()->json([
            'user' => [
                'id' => (string) $user->id,
                'name' => $user->name,
                'username' => $user->username,
                'email' => $user->email,
                'profile_photo_url' => $user->profile_photo_url ?? null,
            ],
            'token' => $token
        ]);
    }

    /**
     * Get current user (using Sanctum auth)
     */
    public function getCurrentUser(Request $request)
    {
        // Get authenticated user from Sanctum
        $user = $request->user();
        
        if (!$user) {
            return response()->json([
                'message' => 'Unauthorized.'
            ], 401);
        }

        return response()->json([
            'user' => [
                'id' => (string) $user->id,
                'name' => $user->name,
                'username' => $user->username,
                'email' => $user->email,
                'profile_photo_url' => $user->profile_photo_url ?? null,
            ]
        ]);
    }

    /**
     * Save FCM token for push notifications
     */
    public function saveFCMToken(Request $request)
    {
        $request->validate([
            'user_id' => 'required|integer|exists:users,id',
            'fcm_token' => 'required|string',
        ]);

        DB::table('users')
            ->where('id', $request->user_id)
            ->update(['fcm_token' => $request->fcm_token]);

        return response()->json([
            'success' => true,
            'message' => 'FCM token saved successfully.'
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

    /**
     * Update user profile (name only)
     */
    public function updateProfile(Request $request)
    {
        $request->validate([
            'user_id' => 'required|integer|exists:users,id',
            'name' => 'required|string|max:255',
        ]);

        try {
            DB::table('users')
                ->where('id', $request->user_id)
                ->update([
                    'name' => $request->name,
                    'updated_at' => now(),
                ]);

            $user = DB::table('users')->where('id', $request->user_id)->first();

            return response()->json([
                'success' => true,
                'message' => 'Profile updated successfully.',
                'user' => [
                    'id' => (string) $user->id,
                    'name' => $user->name,
                    'username' => $user->username,
                    'email' => $user->email,
                    'profile_photo_url' => $user->profile_photo_url ?? null,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update profile.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Change password
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'user_id' => 'required|integer|exists:users,id',
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:6|confirmed',
        ]);

        try {
            $user = DB::table('users')->where('id', $request->user_id)->first();

            // Verify current password
            if (!Hash::check($request->current_password, $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Current password is incorrect.'
                ], 401);
            }

            // Update password
            DB::table('users')
                ->where('id', $request->user_id)
                ->update([
                    'password' => Hash::make($request->new_password),
                    'updated_at' => now(),
                ]);

            return response()->json([
                'success' => true,
                'message' => 'Password changed successfully.'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to change password.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Upload profile photo
     */
    public function uploadProfilePhoto(Request $request)
    {
        $request->validate([
            'user_id' => 'required|integer|exists:users,id',
            'photo' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048', // 2MB max
        ]);

        try {
            $file = $request->file('photo');
            $fileName = 'profile_' . $request->user_id . '_' . time() . '.' . $file->getClientOriginalExtension();
            
            // Save to public/uploads/profiles
            $path = $file->move(public_path('uploads/profiles'), $fileName);
            
            // Generate URL (adjust based on your server configuration)
            $url = url('uploads/profiles/' . $fileName);

            // Update database
            DB::table('users')
                ->where('id', $request->user_id)
                ->update([
                    'profile_photo_url' => $url,
                    'updated_at' => now(),
                ]);

            return response()->json([
                'success' => true,
                'message' => 'Profile photo uploaded successfully.',
                'profile_photo_url' => $url
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to upload profile photo.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}