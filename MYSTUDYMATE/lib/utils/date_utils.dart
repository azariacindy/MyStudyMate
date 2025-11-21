import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class DateUtils {
  // Fungsi untuk mengonversi TimeOfDay menjadi string (HH:mm)
  static String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final parsedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm().format(parsedTime);  // Mengembalikan waktu dalam format "HH:mm"
  }

  // Fungsi untuk mengonversi string waktu (HH:mm) menjadi TimeOfDay
  static TimeOfDay parseTime(String timeString) {
    final timeParts = timeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Fungsi untuk mengonversi DateTime ke format string yang dapat digunakan dalam JSON (yyyy-MM-dd)
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Fungsi untuk mengonversi string tanggal (yyyy-MM-dd) menjadi DateTime
  static DateTime parseDate(String dateString) {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }

  // Fungsi untuk mengonversi DateTime ke string format untuk menampilkan
  static String formatDisplayDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);  // Format seperti "March 14, 2022"
  }

  // Fungsi untuk menambahkan reminder pada waktu tertentu
  static DateTime addReminder(DateTime startTime, int reminderMinutes) {
    return startTime.subtract(Duration(minutes: reminderMinutes));
  }
}
