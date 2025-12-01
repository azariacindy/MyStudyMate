<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreStudyCardRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title'             => 'required|string|max:255',
            'description'       => 'nullable|string|max:1000',
            'material_type'     => 'required|in:text,file',
            'material_content'  => 'required_if:material_type,text|nullable|string',
            'material_file'     => 'required_if:material_type,file|nullable|file|mimes:pdf,doc,docx,txt,ppt,pptx|max:10240',
            
        ];
    }
}