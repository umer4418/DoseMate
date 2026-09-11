import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeUtils {
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static TimeOfDay? parseTime(String value) {
    try {
      final parsed = DateFormat('h:mm a').parse(value.toUpperCase());
      return TimeOfDay(hour: parsed.hour, minute: parsed.minute);
    } catch (_) {
      try {
        final parsed = DateFormat('hh:mm a').parse(value.toUpperCase());
        return TimeOfDay(hour: parsed.hour, minute: parsed.minute);
      } catch (_) {
        return null;
      }
    }
  }

  static int toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;
  static String weekdayName(DateTime date) => DateFormat('EEEE').format(date);
  static String prettyDate(DateTime date) => DateFormat('EEE, d MMM yyyy').format(date);
  static String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  static List<String> generateSlots({
    required String startTime,
    required String endTime,
    int intervalMinutes = 30,
  })
  {
    final start = parseTime(startTime);
    final end = parseTime(endTime);
    if (start == null || end == null) return [];

    var current = toMinutes(start);
    final last = toMinutes(end);
    final slots = <String>[];

    while (current + intervalMinutes <= last) {
      final hour = current ~/ 60;
      final minute = current % 60;
      slots.add(formatTimeOfDay(TimeOfDay(hour: hour, minute: minute)));
      current += intervalMinutes;
    }
    return slots;
  }
}
