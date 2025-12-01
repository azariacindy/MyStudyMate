<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Contracts\Services\StudyCardServiceInterface;
use App\Http\Requests\StoreStudyCardRequest;
use App\Http\Requests\UpdateStudyCardRequest;
use App\Http\Resources\StudyCardResource;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class StudyCardController extends Controller
{
    protected StudyCardServiceInterface $service;

    public function __construct(StudyCardServiceInterface $service)
    {
        $this->service = $service;
    }

    public function index(Request $request): JsonResponse
    {
        $perPage = $request->get('per_page', 15);
        $data = $this->service->getAllUserStudyCards($request->user()->id, $perPage);
        return response()->json([
            'success' => true,
            'data'    => StudyCardResource::collection($data),
        ]);
    }

    public function store(StoreStudyCardRequest $request): JsonResponse
    {
        $studyCard = $this->service->createStudyCard($request->validated(), $request->user()->id);
        return response()->json([
            'success' => true,
            'data'    => new StudyCardResource($studyCard),
        ], 201);
    }

    public function show($id): JsonResponse
    {
        $studyCard = $this->service->getStudyCardById($id);
        if (!$studyCard) {
            return response()->json(['success' => false, 'message' => 'Not found'], 404);
        }
        return response()->json([
            'success' => true,
            'data'    => new StudyCardResource($studyCard),
        ]);
    }

    public function update(UpdateStudyCardRequest $request, $id): JsonResponse
    {
        $studyCard = $this->service->updateStudyCard($id, $request->validated(), $request->user()->id);
        return response()->json([
            'success' => true,
            'data'    => new StudyCardResource($studyCard),
        ]);
    }

    public function destroy(Request $request, $id): JsonResponse
    {
        $this->service->deleteStudyCard($id, $request->user()->id);
        return response()->json([
            'success' => true,
            'message' => 'Study card deleted successfully',
        ]);
    }
}