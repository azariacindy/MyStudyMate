<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class ScheduleController extends Controller
{
    public function index(Request $request)
    {
        $userId = Auth::id();
        $start = $request->get('start', now()->startOfWeek());
        $end = $request->get('end', now()->endOfWeek());

        $schedules = DB::table('schedules')
            ->where('user_id', $userId)
            ->whereBetween('start_time', [$start, $end])
            ->orderBy('start_time', 'asc')
            ->get();

        return response()->json($schedules);
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
            'start_time' => 'required|date',
            'end_time' => 'required|date|after:start_time',
        ]);

        $id = DB::table('schedules')->insertGetId([
            'user_id' => Auth::id(),
            'title' => $request->title,
            'description' => $request->description,
            'start_time' => $request->start_time,
            'end_time' => $request->end_time,
            'created_at' => now(),
            'updated_at' => now(),
        ], 'id');

        return response()->json(['id' => $id, 'message' => 'Schedule created'], 201);
    }

    public function update(Request $request, $id)
    {
        DB::table('schedules')
            ->where('id', $id)
            ->where('user_id', Auth::id())
            ->update($request->only(['title', 'description', 'start_time', 'end_time']) + ['updated_at' => now()]);

        return response()->json(['message' => 'Schedule updated']);
    }

    public function destroy($id)
    {
        DB::table('schedules')
            ->where('id', $id)
            ->where('user_id', Auth::id())
            ->delete();

        return response()->json(['message' => 'Schedule deleted']);
    }
}