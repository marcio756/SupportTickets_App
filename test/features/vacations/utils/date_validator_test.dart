import 'package:flutter_test/flutter_test.dart';
import 'package:supporttickets_app/features/vacations/utils/date_validator.dart';

void main() {
  group('DateValidator Business Rules Tests', () {
    test('Should return error when either date is null', () {
      final result = DateValidator.validateVacationDates(null, DateTime.now());
      expect(result, isNotNull);
    });

    test('Should return error when end date is chronologically before start date', () {
      final start = DateTime.now().add(const Duration(days: 5));
      final end = DateTime.now().add(const Duration(days: 2));
      
      final result = DateValidator.validateVacationDates(start, end);
      expect(result, 'End date must be after start date.');
    });

    test('Should return null (valid) for a correct chronological range', () {
      final start = DateTime.now().add(const Duration(days: 2));
      final end = DateTime.now().add(const Duration(days: 10));
      
      final result = DateValidator.validateVacationDates(start, end);
      expect(result, isNull);
    });
  });
}