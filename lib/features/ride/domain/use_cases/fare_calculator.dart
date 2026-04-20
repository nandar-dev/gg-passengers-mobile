/// Fare calculation logic
class FareCalculator {
  /// Calculate ride fare based on distance and time
  static double calculateFare({
    required double baseFare,
    required double distanceKm,
    required double perKmRate,
    required int durationMinutes,
    required double perMinRate,
    double surgeMultiplier = 1.0,
  }) {
    final distanceFare = distanceKm * perKmRate;
    final timeFare = durationMinutes * perMinRate;
    final baseCost = baseFare + distanceFare + timeFare;
    final totalFare = baseCost * surgeMultiplier;

    return double.parse(totalFare.toStringAsFixed(2));
  }

  /// Calculate surge multiplier based on demand (mock implementation)
  static double calculateSurgeMultiplier(int activeRideRequests) {
    if (activeRideRequests < 5) return 1.0;
    if (activeRideRequests < 15) return 1.25;
    if (activeRideRequests < 30) return 1.5;
    return 2.0;
  }

  /// Estimate ride time in minutes (mock calculation)
  static int estimateTravelTime({
    required double distanceKm,
    bool isPeakHour = false,
  }) {
    // Average speed: 30 km/h in normal traffic, 20 km/h in peak hour
    final avgSpeed = isPeakHour ? 20 : 30;
    final minutes = (distanceKm / avgSpeed * 60).ceil();
    return minutes;
  }
}
