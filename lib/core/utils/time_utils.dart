/// Utility functions for time formatting and calculations
class TimeUtils {
  /// Format duration to human readable string
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Format time to HH:MM format
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format date to DD/MM/YYYY format
  static String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  /// Format date and time to DD/MM/YYYY HH:MM format
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Get relative time string (e.g., "לפני 5 דקות")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'עכשיו';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'לפני $minutes ${minutes == 1 ? 'דקה' : 'דקות'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'לפני $hours ${hours == 1 ? 'שעה' : 'שעות'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'לפני $days ${days == 1 ? 'יום' : 'ימים'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'לפני $weeks ${weeks == 1 ? 'שבוע' : 'שבועות'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'לפני $months ${months == 1 ? 'חודש' : 'חודשים'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'לפני $years ${years == 1 ? 'שנה' : 'שנים'}';
    }
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Get greeting based on current time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'בוקר טוב';
    } else if (hour < 17) {
      return 'צהריים טובים';
    } else if (hour < 21) {
      return 'ערב טוב';
    } else {
      return 'לילה טוב';
    }
  }

  /// Calculate age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
} 