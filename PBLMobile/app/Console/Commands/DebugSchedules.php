<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Schedule;
use Carbon\Carbon;

class DebugSchedules extends Command
{
    protected $signature = 'schedule:debug';
    protected $description = 'Debug schedules and reminders';

    public function handle()
    {
        $this->info('🔍 Checking Schedules...');
        $this->newLine();
        
        // Total schedules
        $total = Schedule::count();
        $this->info("📊 Total schedules: {$total}");
        $this->newLine();
        
        // Latest schedule
        $latest = Schedule::latest()->first();
        if ($latest) {
            $this->info('📅 Latest Schedule:');
            $this->line("   ID: {$latest->id}");
            $this->line("   Date: {$latest->date}");
            $this->line("   Start Time: {$latest->start_time}");
            $this->line("   Reminder: " . ($latest->reminder ? '✅ ON' : '❌ OFF'));
            $this->line("   Notification Sent: " . ($latest->notification_sent ? '✅ YES' : '❌ NO'));
            $this->newLine();
            
            // Calculate when notification should be sent
            $dateString = Carbon::parse($latest->date)->format('Y-m-d');
            $timeString = Carbon::parse($latest->start_time)->format('H:i:s');
            $scheduleDateTime = Carbon::parse($dateString . ' ' . $timeString);
            $notificationTime = $scheduleDateTime->copy()->subMinutes(30);
            $now = Carbon::now();
            
            $this->info('⏰ Timing Analysis:');
            $this->line("   Current Time: {$now->format('Y-m-d H:i:s')}");
            $this->line("   Schedule Time: {$scheduleDateTime->format('Y-m-d H:i:s')}");
            $this->line("   Notification Time: {$notificationTime->format('Y-m-d H:i:s')}");
            $this->newLine();
            
            if ($now->gte($notificationTime) && $now->lt($scheduleDateTime)) {
                $this->warn('⚠️  Should send notification NOW!');
            } elseif ($now->lt($notificationTime)) {
                $minutesUntil = $now->diffInMinutes($notificationTime);
                $this->info("⏳ Notification in {$minutesUntil} minutes");
            } else {
                $this->comment('✓ Schedule time passed');
            }
        }
        
        $this->newLine();
        
        // Check schedules that need reminders
        $now = Carbon::now();
        $schedules = Schedule::where('reminder', true)
            ->where('notification_sent', false)
            ->get();
            
        $this->info("🔔 Schedules with reminder ON (not sent): {$schedules->count()}");
        
        foreach ($schedules as $schedule) {
            $dateString = Carbon::parse($schedule->date)->format('Y-m-d');
            $timeString = Carbon::parse($schedule->start_time)->format('H:i:s');
            $scheduleDateTime = Carbon::parse($dateString . ' ' . $timeString);
            $notificationTime = $scheduleDateTime->copy()->subMinutes(30);
            
            $this->line("   - Schedule #{$schedule->id}: {$schedule->start_time} (notify at {$notificationTime->format('H:i')})");
        }
        
        return 0;
    }
}
