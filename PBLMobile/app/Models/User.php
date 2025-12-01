<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Hash;

class User extends Model
{
    use HasFactory;

    /**
     * Nama tabel yang digunakan.
     */
    protected $table = 'users';

    /**
     * Kolom yang bisa diisi secara massal.
     */
    protected $fillable = [
        'name',
        'username',
        'email',
        'password',
        'email_verified_at',
        'remember_token',
    ];

    /**
     * Kolom yang disembunyikan saat serialisasi (misal ke JSON).
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Kolom tanggal yang harus di-cast ke Carbon instance.
     */
    protected $dates = [
        'email_verified_at',
        'created_at',
        'updated_at',
    ];

    /**
     * Mutator: otomatis hash password saat diset.
     */
    public function setPasswordAttribute($value)
    {
        $this->attributes['password'] = Hash::make($value);
    }

    /**
     * Accessor: dapatkan nama lengkap (opsional).
     */
    public function getFullNameAttribute()
    {
        return $this->name;
    }

    // Add these relationships
    public function studyCards()
    {
        return $this->hasMany(StudyCard::class);
    }
    public function quizAttempts()
    {
        return $this->hasMany(UserQuizAttempt::class);
    }
    
    // Get completed attempts only
    public function completedAttempts()
    {
        return $this->hasMany(UserQuizAttempt::class)->where('status', 'completed');
    }
}