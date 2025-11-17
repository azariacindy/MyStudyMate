<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreScheduleRequest;
use App\Http\Requests\UpdateScheduleRequest;
use App\Http\Resources\ScheduleResource;
use App\Models\Schedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class ScheduleController extends Controller
{
    /**
     * Display a listing of schedules.
     * GET /api/schedules
     */
    public function index(Request $request)
    {
        try {
            $userId = Auth::id() ?? 1; // Default to user ID 1 for testing
            
            $schedules = Schedule::forUser($userId)
                ->orderBy('date', 'desc')
                ->orderBy('start_time', 'asc')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Schedules retrieved successfully',
                'data' => ScheduleResource::collection($schedules),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve schedules',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Store a newly created schedule.
     * POST /api/schedules
     */
    public function store(StoreScheduleRequest $request)
    {
        try {
            $userId = Auth::id() ?? 1; // Default to user ID 1 for testing

            // Check for schedule conflicts
            $hasConflict = Schedule::checkConflict(
                $userId,
                $request->date,
                $request->start_time,
                $request->end_time
            );

            if ($hasConflict) {
                return response()->json([
                    'success' => false,
                    'message' => 'Schedule conflict detected. You already have a schedule at this time.',
                    'has_conflict' => true,
                ], 422);
            }

            // Create schedule
            $schedule = Schedule::create([
                'user_id' => $userId,
                'title' => $request->title,
                'description' => $request->description,
                'date' => $request->date,
                'start_time' => $request->start_time,
                'end_time' => $request->end_time,
                'location' => $request->location,
                'lecturer' => $request->lecturer,
                'color' => $request->color,
                'type' => $request->type,
                'has_reminder' => $request->has_reminder ?? true,
                'reminder_minutes' => $request->reminder_minutes ?? 30,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Schedule created successfully',
                'data' => new ScheduleResource($schedule),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create schedule',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Display the specified schedule.
     * GET /api/schedules/{id}
     */
    public function show($id)
    {
        try {
            $schedule = Schedule::forUser(Auth::id() ?? 1)->findOrFail($id);

            return response()->json([
                'success' => true,
                'message' => 'Schedule retrieved successfully',
                'data' => new ScheduleResource($schedule),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Schedule not found',
                'error' => $e->getMessage(),
            ], 404);
        }
    }

    /**
     * Update the specified schedule.
     * PUT /api/schedules/{id}
     */
    public function update(UpdateScheduleRequest $request, $id)
    {
        try {
            $userId = Auth::id() ?? 1;
            $schedule = Schedule::forUser($userId)->findOrFail($id);

            // Check for conflicts (excluding current schedule)
            if ($request->has('date') || $request->has('start_time') || $request->has('end_time')) {
                $date = $request->date ?? $schedule->date->format('Y-m-d');
                $startTime = $request->start_time ?? date('H:i', strtotime($schedule->start_time));
                $endTime = $request->end_time ?? date('H:i', strtotime($schedule->end_time));

                $hasConflict = Schedule::checkConflict(
                    $userId,
                    $date,
                    $startTime,
                    $endTime,
                    $id
                );

                if ($hasConflict) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Schedule conflict detected',
                        'has_conflict' => true,
                    ], 422);
                }
            }

            $schedule->update($request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Schedule updated successfully',
                'data' => new ScheduleResource($schedule),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update schedule',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove the specified schedule.
     * DELETE /api/schedules/{id}
     */
    public function destroy($id)
    {
        try {
            $schedule = Schedule::forUser(Auth::id() ?? 1)->findOrFail($id);
            $schedule->delete();

            return response()->json([
                'success' => true,
                'message' => 'Schedule deleted successfully',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete schedule',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get schedules by specific date.
     * GET /api/schedules/date/{date}
     */
    public function getByDate($date)
    {
        try {
            $schedules = Schedule::forUser(Auth::id() ?? 1)
                ->onDate($date)
                ->orderBy('start_time')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Schedules retrieved successfully',
                'data' => ScheduleResource::collection($schedules),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve schedules',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get schedules by date range.
     * GET /api/schedules/range?start_date=xxx&end_date=xxx
     */
    public function getByDateRange(Request $request)
    {
        try {
            $request->validate([
                'start_date' => 'required|date',
                'end_date' => 'required|date|after_or_equal:start_date',
            ]);

            $schedules = Schedule::forUser(Auth::id() ?? 1)
                ->betweenDates($request->start_date, $request->end_date)
                ->orderBy('date')
                ->orderBy('start_time')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Schedules retrieved successfully',
                'data' => ScheduleResource::collection($schedules),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve schedules',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get upcoming schedules.
     * GET /api/schedules/upcoming?limit=5
     */
    public function getUpcoming(Request $request)
    {
        try {
            $limit = $request->input('limit', 5);

            $schedules = Schedule::forUser(Auth::id() ?? 1)
                ->upcoming()
                ->incomplete()
                ->limit($limit)
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Upcoming schedules retrieved successfully',
                'data' => ScheduleResource::collection($schedules),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve upcoming schedules',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Toggle schedule completion status.
     * PATCH /api/schedules/{id}/toggle-complete
     */
    public function toggleComplete(Request $request, $id)
    {
        try {
            $schedule = Schedule::forUser(Auth::id() ?? 1)->findOrFail($id);
            
            $schedule->is_completed = $request->input('is_completed', !$schedule->is_completed);
            $schedule->save();

            return response()->json([
                'success' => true,
                'message' => 'Schedule completion status updated',
                'data' => new ScheduleResource($schedule),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update schedule',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Check schedule conflict.
     * POST /api/schedules/check-conflict
     */
    public function checkConflict(Request $request)
    {
        try {
            $request->validate([
                'date' => 'required|date',
                'start_time' => 'required|date_format:H:i',
                'end_time' => 'required|date_format:H:i|after:start_time',
                'exclude_id' => 'nullable|exists:schedules,id',
            ]);

            $hasConflict = Schedule::checkConflict(
                Auth::id() ?? 1,
                $request->date,
                $request->start_time,
                $request->end_time,
                $request->exclude_id
            );

            return response()->json([
                'success' => true,
                'has_conflict' => $hasConflict,
                'message' => $hasConflict ? 'Schedule conflict detected' : 'No conflict',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to check conflict',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get schedule statistics.
     * GET /api/schedules/stats
     */
    public function getStats()
    {
        try {
            $userId = Auth::id() ?? 1;
            $today = Carbon::today();

            $stats = [
                'total' => Schedule::forUser($userId)->count(),
                'completed' => Schedule::forUser($userId)->completed()->count(),
                'upcoming' => Schedule::forUser($userId)->upcoming()->incomplete()->count(),
                'today' => Schedule::forUser($userId)->onDate($today)->count(),
                'this_week' => Schedule::forUser($userId)
                    ->betweenDates($today, $today->copy()->addDays(7))
                    ->count(),
            ];

            return response()->json([
                'success' => true,
                'message' => 'Statistics retrieved successfully',
                'data' => $stats,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve statistics',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}