import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/model/map/transport_mode.dart';
import 'package:sadak/service/interface/map/i_pricing_service.dart';

/// Implementation of pricing service with hybrid pricing model
/// Uses transport mode cost multipliers combined with distance/duration
class PricingService implements IPricingService {
  // Base pricing values in €
  static const double basePricePerKm = 0.15;
  static const double basePricePerHour = 2.5;

  @override
  double calculate({
    required double distance,
    required double duration,
    required ORSProfile profile,
  }) {
    // Get the transport mode from profile
    final transportMode = _mapProfileToTransportMode(profile);

    // Calculate base price from distance and duration
    final distanceInKm = distance / 1000;
    final durationInHours = duration / 3600;

    final basePrice = (distanceInKm * basePricePerKm) + (durationInHours * basePricePerHour);

    // Apply transport mode multiplier
    final finalPrice = basePrice * transportMode.costMultiplier;

    // Ensure minimum price
    return finalPrice < 1.0 ? 1.0 : finalPrice;
  }

  /// Map ORS profile to transport mode for pricing
  TransportMode _mapProfileToTransportMode(ORSProfile profile) {
    return switch (profile) {
      ORSProfile.drivingCar => TransportMode.toto,
      ORSProfile.drivingHgv => TransportMode.bus,
      ORSProfile.cyclingRoad => TransportMode.localTrain,
      ORSProfile.cyclingMountain => TransportMode.localTrain,
      ORSProfile.cyclingElectric => TransportMode.localTrain,
      ORSProfile.footWalking => TransportMode.metro,
      ORSProfile.footHiking => TransportMode.metro,
      ORSProfile.wheelchair => TransportMode.metro,
    };
  }
}
