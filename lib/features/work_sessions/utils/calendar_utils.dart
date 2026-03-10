/// Utility class responsible for translating time intervals into spatial 
/// dimensions (pixels) for calendar grid rendering.
class CalendarUtils {
  
  /// Calculates the vertical position (Y-axis) of a session block relative to midnight.
  /// 
  /// @param time The starting timestamp of the session.
  /// @param hourHeight The height in pixels representing a full hour (e.g., 60.0).
  /// @return The precise top offset in pixels.
  static double calculateTopOffset(DateTime time, double hourHeight) {
    final double hours = time.hour + (time.minute / 60.0);
    return hours * hourHeight;
  }

  /// Calculates the vertical height of a session block based on its total duration.
  /// Falls back to the current device time if the session is still actively running.
  /// 
  /// @param start The starting timestamp.
  /// @param end The optional ending timestamp.
  /// @param hourHeight The height in pixels representing a full hour.
  /// @return The absolute height in pixels.
  static double calculateSessionHeight(DateTime start, DateTime? end, double hourHeight) {
    final DateTime targetEnd = end ?? DateTime.now();
    int durationInMinutes = targetEnd.difference(start).inMinutes;
    
    if (durationInMinutes < 15) {
      durationInMinutes = 15; // Enforce minimum visual height for readability
    }

    return (durationInMinutes / 60.0) * hourHeight;
  }

  /// Normalizes the Dart weekday representation to a 0-indexed integer 
  /// where 0 represents Monday and 6 represents Sunday.
  /// 
  /// @param date The date to analyze.
  /// @return An integer from 0 to 6.
  static int getNormalizedWeekdayIndex(DateTime date) {
    return date.weekday - 1;
  }
}