<?php

// use App\Http\Controllers\AssignmentController; // Commented - file has double extension .php.php
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ScheduleController;
use App\Http\Controllers\StudyCardController;
use App\Http\Controllers\TaskController;
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
Route::get('/current-user', [AuthController::class, 'getCurrentUser']);
Route::post('/save-fcm-token', [AuthController::class, 'saveFCMToken']);

// 🔒 Assignment routes → COMMENTED OUT - AssignmentController has wrong filename
// Route::prefix('assignments')->group(function () {
//     Route::get('/', [AssignmentController::class, 'index']); // GET /api/assignments
//     Route::post('/', [AssignmentController::class, 'store']);
//     Route::put('/{id}', [AssignmentController::class, 'update']);
//     Route::delete('/{id}', [AssignmentController::class, 'destroy']);
//     Route::patch('/{id}/mark-done', [AssignmentController::class, 'markAsDone']);
//     Route::get('/weekly-progress', [AssignmentController::class, 'weeklyProgress']);
// });

// 🔒 Schedule routes → prefix: /schedules
Route::prefix('schedules')->group(function () {
    Route::get('/', [ScheduleController::class, 'index']); // GET /api/schedules
    Route::post('/', [ScheduleController::class, 'store']);
    Route::get('/stats', [ScheduleController::class, 'getStats']);
    Route::get('/upcoming', [ScheduleController::class, 'getUpcoming']);
    Route::get('/date/{date}', [ScheduleController::class, 'getByDate']);
    Route::get('/range', [ScheduleController::class, 'getByDateRange']);
    Route::post('/check-conflict', [ScheduleController::class, 'checkConflict']);
    Route::get('/{id}', [ScheduleController::class, 'show']);
    Route::put('/{id}', [ScheduleController::class, 'update']);
    Route::patch('/{id}/toggle-complete', [ScheduleController::class, 'toggleComplete']);
    Route::delete('/{id}', [ScheduleController::class, 'destroy']);
});

// 🔒 Task routes → prefix: /tasks
Route::prefix('tasks')->group(function () {
    Route::get('/', [TaskController::class, 'index']); // GET /api/tasks
    Route::post('/', [TaskController::class, 'store']);
    Route::get('/stats', [TaskController::class, 'getStats']);
    Route::get('/upcoming', [TaskController::class, 'getUpcoming']);
    Route::get('/range', [TaskController::class, 'getByDeadlineRange']);
    Route::get('/{id}', [TaskController::class, 'show']);
    Route::put('/{id}', [TaskController::class, 'update']);
    Route::patch('/{id}/toggle-complete', [TaskController::class, 'toggleComplete']);
    Route::delete('/{id}', [TaskController::class, 'destroy']);
});

// 🔒 Study Cards & Quiz routes → prefix: /study-cards
Route::prefix('study-cards')->group(function () {
    Route::get('/', [StudyCardController::class, 'index']); // GET /api/study-cards
    Route::post('/', [StudyCardController::class, 'store']); // POST /api/study-cards
    Route::post('/{id}/generate-quiz', [StudyCardController::class, 'generateQuiz']); // POST /api/study-cards/{id}/generate-quiz
    Route::delete('/{id}', [StudyCardController::class, 'destroy']); // DELETE /api/study-cards/{id}
});

// Quiz routes → prefix: /quizzes
Route::prefix('quizzes')->group(function () {
    Route::get('/{id}', [StudyCardController::class, 'getQuiz']); // GET /api/quizzes/{id}
    Route::post('/{id}/submit', [StudyCardController::class, 'submitQuiz']); // POST /api/quizzes/{id}/submit
    Route::get('/{id}/attempts', [StudyCardController::class, 'getQuizAttempts']); // GET /api/quizzes/{id}/attempts
});
