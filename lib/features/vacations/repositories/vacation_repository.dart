import 'package:supporttickets_app/core/network/api_client.dart';
import 'package:supporttickets_app/features/vacations/models/vacation_models.dart';

/// Handles all external data fetching and mutation operations related to Vacations.
/// Decouples the UI and ViewModels from direct network calls.
class VacationRepository {
  final ApiClient _apiClient;

  VacationRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Retrieves the structured hierarchical calendar data for a specific year.
  /// * @param year The target year to fetch the calendar for.
  /// @return A complete list of teams, containing their members and respective vacation requests.
  Future<List<VacationTeam>> getCalendarData({required int year}) async {
    final response = await _apiClient.get(
      '/api/vacations/calendar',
      queryParameters: {'year': year},
    );

    final data = response['data'] as Map<String, dynamic>?;
    if (data == null || !data.containsKey('teams')) {
      return [];
    }

    final teamsList = data['teams'] as List<dynamic>;
    return teamsList.map((json) => VacationTeam.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Submits a new vacation booking request to the backend.
  /// * @param startDate The first day of the vacation.
  /// @param endDate The last day of the vacation.
  /// @return The newly created Vacation object.
  Future<Vacation> bookVacation({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Ensuring dates are sent in strictly 'YYYY-MM-DD' format as expected by Laravel
    final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    final response = await _apiClient.post(
      '/api/vacations',
      data: {
        'start_date': startStr,
        'end_date': endStr,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    return Vacation.fromJson(data);
  }
}