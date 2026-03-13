/// Encapsulates domain-specific validation logic for vacation date selections.
/// Extracted to maintain SRP and keep the UI controllers lean.
class DateValidator {
  static String? validateVacationDates(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return 'Please select both start and end dates.';
    }
    if (end.isBefore(start)) {
      return 'End date must be after start date.';
    }
    // Business rule: Vacations should ideally be scheduled in the future
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (start.isBefore(today)) {
      return 'Start date cannot be in the past.';
    }
    return null;
  }
}