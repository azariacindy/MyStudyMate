<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateStudyCardRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title'             => 'sometimes|required|string|max:255',
            'description'       => 'nullable|string|max:1000',
            'material_content'  => 'nullable|string',
            'material_file'     => 'nullable|file|mimes:pdf,doc,docx,txt,ppt,pptx|max:10240',
            
        ];
    }
}