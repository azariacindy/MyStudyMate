<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreScheduleRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true; // Ubah ke true
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'date' => 'required|date|after_or_equal:today',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i|after:start_time',
            'location' => 'nullable|string|max:255',
            'lecturer' => 'nullable|string|max:255',
            'color' => 'nullable|string|regex:/^#[0-9A-Fa-f]{6}$/',
            'type' => 'required|in:lecture,lab,meeting,event,assignment,other',
            'has_reminder' => 'nullable|boolean',
            'reminder_minutes' => 'nullable|integer|min:1|max:1440',
        ];
    }

    /**
     * Get custom error messages
     */
    public function messages(): array
    {
        return [
            'title.required' => 'Judul schedule wajib diisi',
            'title.max' => 'Judul maksimal 255 karakter',
            'date.required' => 'Tanggal wajib diisi',
            'date.after_or_equal' => 'Tanggal tidak boleh sebelum hari ini',
            'start_time.required' => 'Waktu mulai wajib diisi',
            'start_time.date_format' => 'Format waktu harus HH:mm',
            'end_time.required' => 'Waktu selesai wajib diisi',
            'end_time.after' => 'Waktu selesai harus setelah waktu mulai',
            'type.required' => 'Tipe schedule wajib dipilih',
            'type.in' => 'Tipe schedule tidak valid',
            'color.regex' => 'Format warna harus hex (#RRGGBB)',
        ];
    }
}