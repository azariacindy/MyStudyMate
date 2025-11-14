<?php

use App\Http\Controllers\AssignmentController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ScheduleController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// routes/api.php TEST
Route::get('/test', fn() => response()->json(['message' => 'Laravel reachable!']));

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout']);

// 🔒 Assignment routes → prefix: /assignments
Route::prefix('assignments')->group(function () {
    Route::get('/', [AssignmentController::class, 'index']); // GET /api/assignments
    Route::post('/', [AssignmentController::class, 'store']);
    Route::put('/{id}', [AssignmentController::class, 'update']);
    Route::delete('/{id}', [AssignmentController::class, 'destroy']);
    Route::patch('/{id}/mark-done', [AssignmentController::class, 'markAsDone']);
    Route::get('/weekly-progress', [AssignmentController::class, 'weeklyProgress']);
});

// 🔒 Schedule routes → prefix: /schedules
Route::prefix('schedules')->group(function () {
    Route::get('/', [ScheduleController::class, 'index']); // GET /api/schedules
    Route::post('/', [ScheduleController::class, 'store']);
    Route::put('/{id}', [ScheduleController::class, 'update']);
    Route::delete('/{id}', [ScheduleController::class, 'destroy']);
});
