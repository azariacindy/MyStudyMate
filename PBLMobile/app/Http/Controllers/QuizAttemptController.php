<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Contracts\Services\QuizAttemptServiceInterface;
use App\Http\Requests\StoreQuizAttemptRequest;
use App\Http\Resources\QuizAttemptResource;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class QuizAttemptController extends Controller
{
    protected QuizAttemptServiceInterface $service;

    public function __construct(QuizAttemptServiceInterface $service)
    {
        $this->service = $service;
    }

    // Mulai quiz attempt
    public function store(StoreQuizAttemptRequest $request): JsonResponse
    {
        $userId = $request->user()->id;
        $quizId = $request->input('quiz_id');
        
        $attempt = $this->service->startQuizAttempt($quizId, $userId);
        
        return response()->json([
            'success' => true,
            'message' => 'Quiz attempt started',
            'data'    => new QuizAttemptResource($attempt),
        ], 201);
    }

    // List attempt user
    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;
        $perPage = $request->get('per_page', 15);
        
        $attempts = $this->service->getUserAttempts($userId, $perPage);
        
        return response()->json([
            'success' => true,
            'data'    => QuizAttemptResource::collection($attempts),
        ]);
    }

    // Detail attempt
    public function show(Request $request, $id): JsonResponse
    {
        $attempt = $this->service->getUserAttempts($request->user()->id)
            ->where('id', $id)
            ->first();
            
        if (!$attempt) {
            return response()->json(['success' => false, 'message' => 'Attempt not found'], 404);
        }
        
        return response()->json([
            'success' => true,
            'data'    => new QuizAttemptResource($attempt),
        ]);
    }
}