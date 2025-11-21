<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Assignment extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'title',
        'description',
        'deadline',
        'is_done',
        'color',
        'has_reminder',
        'reminder_minutes',
        'last_notification_type',
    ];

    protected $casts = [
        'deadline' => 'datetime',
        'is_done' => 'boolean',
        'has_reminder' => 'boolean',
        'reminder_minutes' => 'integer',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Scopes
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopePending($query)
    {
        return $query->where('is_done', false);
    }

    public function scopeCompleted($query)
    {
        return $query->where('is_done', true);
    }

    public function scopeWeekly($query)
    {
        $startOfWeek = Carbon::now()->startOfWeek();
        $endOfWeek = Carbon::now()->endOfWeek();
        
        return $query->whereBetween('deadline', [$startOfWeek, $endOfWeek]);
    }

    public function scopeOverdue($query)
    {
        return $query->where('is_done', false)
                     ->where('deadline', '<', Carbon::now());
    }

    public function scopeDueToday($query)
    {
        return $query->where('is_done', false)
                     ->whereDate('deadline', Carbon::today());
    }

    public function scopeUpcoming($query)
    {
        return $query->where('is_done', false)
                     ->where('deadline', '>', Carbon::now())
                     ->orderBy('deadline', 'asc');
    }

    // Accessors
    public function getIsOverdueAttribute()
    {
        return !$this->is_done && $this->deadline->isPast();
    }

    public function getIsDueTodayAttribute()
    {
        return !$this->is_done && $this->deadline->isToday();
    }

    /**
     * Get priority level based on deadline proximity
     * Returns: 'critical', 'high', 'medium', 'low'
     */
    public function getPriorityAttribute()
    {
        if ($this->is_done) {
            return 'completed';
        }

        $now = Carbon::now();
        $daysUntilDeadline = $now->diffInDays($this->deadline, false);

        if ($this->deadline->isPast()) {
            // Overdue
            return 'critical';
        } elseif ($daysUntilDeadline <= 1) {
            // Due today or tomorrow
            return 'high';
        } elseif ($daysUntilDeadline <= 3) {
            // Due in 2-3 days
            return 'medium';
        } else {
            // More than 3 days
            return 'low';
        }
    }

    /**
     * Get priority label for display
     */
    public function getPriorityLabelAttribute()
    {
        $priority = $this->priority;
        
        $labels = [
            'critical' => 'Overdue',
            'high' => 'Urgent',
            'medium' => 'Soon',
            'low' => 'Upcoming',
            'completed' => 'Done',
        ];

        return $labels[$priority] ?? 'Unknown';
    }

    /**
     * Get days until deadline (negative if overdue)
     */
    public function getDaysUntilDeadlineAttribute()
    {
        $now = Carbon::now();
        return (int) $now->diffInDays($this->deadline, false);
    }
}
