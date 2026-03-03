import 'package:intl/intl.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isToday() {
    final now = DateTime.now();
    return isSameDate(now);
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDate(yesterday);
  }
}

String timeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (date.isToday()) {
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    }
  } else if (date.isYesterday()) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  }
}

String convertToIso8601(String date, String time, String timezoneOffset) {
  String dateTimeStr = "$date $time";

  // Define the input format (17/01/2025 11:25 AM)
  DateFormat inputFormat = DateFormat("dd/MM/yyyy hh:mm a");

  // Parse the string to a DateTime object
  DateTime parsedDateTime = inputFormat.parse(dateTimeStr);

  // Apply the timezone offset
  // Timezone offset should be in "+01:00" or "-02:00" format
  Duration offsetDuration = Duration(
    hours: int.parse(timezoneOffset.split(":")[0]),
    minutes: int.parse(timezoneOffset.split(":")[1]),
  );
  parsedDateTime = parsedDateTime.toUtc().add(offsetDuration);

  // Convert to ISO 8601 string
  // Format to "yyyy-MM-ddTHH:mm:ss+hh:mm"
  String iso8601Date = DateFormat("yyyy-MM-ddTHH:mm:ss").format(parsedDateTime);
  String iso8601Offset =
      timezoneOffset.startsWith("-") ? timezoneOffset : "+$timezoneOffset";
  print("$iso8601Date$iso8601Offset");

  return "$iso8601Date$iso8601Offset";
}

String getTimezoneOffset() {
  // Get the current DateTime
  DateTime now = DateTime.now();

  // Get the timezone offset as a Duration
  Duration offset = now.timeZoneOffset;

  // Determine the sign of the offset
  String sign = offset.isNegative ? "-" : "+";

  // Format the offset into "+hh:mm" or "-hh:mm"
  int hours = offset.inHours.abs();
  int minutes = offset.inMinutes.remainder(60).abs();

  return "$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
}

String formatTime(int millisecondsSinceEpoch) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
    millisecondsSinceEpoch,
  );
  return DateFormat('h:mma').format(dateTime).toLowerCase(); // '9:51am'
}

String formatDate(int millisecondsSinceEpoch) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
    millisecondsSinceEpoch,
  );
  return DateFormat("MMM d").format(dateTime); // "May 19"
}

String formatDateTimeToLocal(String dateTimeString, {String? timeZone}) {
  DateTime dateTime = DateTime.parse(dateTimeString);

  // Convert to local timezone if no specific timezone is provided
  if (timeZone == null) {
    dateTime = dateTime.toLocal();
  } else {
    // Handle specific timezone conversion (requires additional package if needed)
    // Example: You can use the `timezone` package if precise time zone conversion is required
  }

  return DateFormat('h:mm a').format(dateTime);
}

String formatDateTimeForGrouping(DateTime dateTime) {
  DateTime now = DateTime.now();
  DateTime yesterday = now.subtract(const Duration(days: 1));

  // Start of this week (Monday)
  DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  dateTime = dateTime.toLocal();
  // Start of this month
  DateTime startOfMonth = DateTime(now.year, now.month, 1);

  if (isSameDay(dateTime, now)) {
    return 'Today';
  } else if (isSameDay(dateTime, yesterday)) {
    return 'Yesterday';
  } else if (dateTime.isAfter(startOfWeek)) {
    return 'This Week';
  } else if (dateTime.isAfter(startOfMonth)) {
    return 'This Month';
  } else {
    return DateFormat('d, MMM, y').format(dateTime);
  }
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatDateIso(String isoDate) {
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return isoDate;
  return DateFormat('MMM dd').format(parsed);
}
