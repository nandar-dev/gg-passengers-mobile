import 'package:flutter_test/flutter_test.dart';
import 'package:gg/features/ride/domain/use_cases/fare_calculator.dart';

void main() {
  group('FareCalculator', () {
    group('calculateFare', () {
      test('calculates fare with base + distance + time', () {
        final fare = FareCalculator.calculateFare(
          baseFare: 2.0,
          distanceKm: 10.0,
          perKmRate: 1.5,
          durationMinutes: 20,
          perMinRate: 0.25,
          surgeMultiplier: 1.0,
        );

        // Expected: 2.0 + (10 * 1.5) + (20 * 0.25) = 2.0 + 15.0 + 5.0 = 22.0
        expect(fare, 22.0);
      });

      test('applies surge multiplier correctly', () {
        final normalFare = FareCalculator.calculateFare(
          baseFare: 2.0,
          distanceKm: 10.0,
          perKmRate: 1.5,
          durationMinutes: 20,
          perMinRate: 0.25,
          surgeMultiplier: 1.0,
        );

        final surgeFare = FareCalculator.calculateFare(
          baseFare: 2.0,
          distanceKm: 10.0,
          perKmRate: 1.5,
          durationMinutes: 20,
          perMinRate: 0.25,
          surgeMultiplier: 2.0,
        );

        expect(surgeFare, normalFare * 2);
        expect(surgeFare, 44.0);
      });

      test('handles zero distance', () {
        final fare = FareCalculator.calculateFare(
          baseFare: 3.0,
          distanceKm: 0.0,
          perKmRate: 1.5,
          durationMinutes: 5,
          perMinRate: 0.25,
          surgeMultiplier: 1.0,
        );

        // Expected: 3.0 + 0 + 1.25 = 4.25
        expect(fare, 4.25);
      });

      test('formats fare to 2 decimal places', () {
        final fare = FareCalculator.calculateFare(
          baseFare: 2.5,
          distanceKm: 3.33,
          perKmRate: 1.5,
          durationMinutes: 7,
          perMinRate: 0.33,
          surgeMultiplier: 1.0,
        );

        // Should not have more than 2 decimals
        final decimalPlaces = fare.toString().split('.').last.length;
        expect(decimalPlaces, lessThanOrEqualTo(2));
      });
    });

    group('calculateSurgeMultiplier', () {
      test('returns 1.0 for low demand (< 5 active rides)', () {
        expect(FareCalculator.calculateSurgeMultiplier(0), 1.0);
        expect(FareCalculator.calculateSurgeMultiplier(4), 1.0);
      });

      test('returns 1.25 for medium demand (5-14 active rides)', () {
        expect(FareCalculator.calculateSurgeMultiplier(5), 1.25);
        expect(FareCalculator.calculateSurgeMultiplier(10), 1.25);
        expect(FareCalculator.calculateSurgeMultiplier(14), 1.25);
      });

      test('returns 1.5 for high demand (15-29 active rides)', () {
        expect(FareCalculator.calculateSurgeMultiplier(15), 1.5);
        expect(FareCalculator.calculateSurgeMultiplier(20), 1.5);
        expect(FareCalculator.calculateSurgeMultiplier(29), 1.5);
      });

      test('returns 2.0 for very high demand (30+ active rides)', () {
        expect(FareCalculator.calculateSurgeMultiplier(30), 2.0);
        expect(FareCalculator.calculateSurgeMultiplier(100), 2.0);
      });
    });

    group('estimateTravelTime', () {
      test('calculates travel time in normal traffic', () {
        final time = FareCalculator.estimateTravelTime(
          distanceKm: 30.0,
          isPeakHour: false,
        );

        // At 30 km/h: 30 km / 30 km/h * 60 = 60 minutes
        expect(time, 60);
      });

      test('calculates travel time in peak hour traffic', () {
        final time = FareCalculator.estimateTravelTime(
          distanceKm: 30.0,
          isPeakHour: true,
        );

        // At 20 km/h: 30 km / 20 km/h * 60 = 90 minutes
        expect(time, 90);
      });

      test('rounds up for partial minutes', () {
        final time = FareCalculator.estimateTravelTime(
          distanceKm: 5.5,
          isPeakHour: false,
        );

        // At 30 km/h: 5.5 / 30 * 60 = 11 minutes (ceil)
        expect(time, 11);
      });

      test('handles very short distances', () {
        final time = FareCalculator.estimateTravelTime(
          distanceKm: 0.1,
          isPeakHour: false,
        );

        // Minimum should be 1 minute
        expect(time, isPositive);
      });
    });
  });
}
