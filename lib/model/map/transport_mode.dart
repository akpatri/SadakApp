import 'package:flutter/material.dart';
import 'package:open_route_service/open_route_service.dart';

/// Public transport modes supported by Sadak
enum TransportMode {
  toto,       // Ride-sharing (Uber/Toto-like)
  ferry,      // Water transport
  bus,        // Public bus
  train,      // Intercity/long-distance train
  localTrain, // Local/suburban train
  metro,      // Subway/metro/rapid transit
  ;

  /// Maps transport mode to ORS routing profile for distance calculation
  ORSProfile getRoutingProfile() {
    return switch (this) {
      TransportMode.toto => ORSProfile.drivingCar,
      TransportMode.ferry => ORSProfile.drivingCar, // Use car routing for ferry routes
      TransportMode.bus => ORSProfile.drivingCar,
      TransportMode.train => ORSProfile.drivingCar,
      TransportMode.localTrain => ORSProfile.drivingCar,
      TransportMode.metro => ORSProfile.footWalking, // Metro uses walking from stations
    };
  }

  /// Get display name for UI
  String get displayName {
    return switch (this) {
      TransportMode.toto => 'Toto',
      TransportMode.ferry => 'Ferry',
      TransportMode.bus => 'Bus',
      TransportMode.train => 'Train',
      TransportMode.localTrain => 'Local Train',
      TransportMode.metro => 'Metro',
    };
  }

  /// Get icon for this transport mode
  IconData get icon {
    return switch (this) {
      TransportMode.toto => Icons.local_taxi,
      TransportMode.ferry => Icons.directions_boat,
      TransportMode.bus => Icons.directions_bus,
      TransportMode.train => Icons.train,
      TransportMode.localTrain => Icons.tram,
      TransportMode.metro => Icons.subway,
    };
  }

  /// Get color for this transport mode
  Color get color {
    return switch (this) {
      TransportMode.toto => const Color(0xFFFFC107), // Amber/Yellow
      TransportMode.ferry => const Color(0xFF2196F3), // Blue
      TransportMode.bus => const Color(0xFF4CAF50), // Green
      TransportMode.train => const Color(0xFF9C27B0), // Purple
      TransportMode.localTrain => const Color(0xFFFF5722), // Deep Orange
      TransportMode.metro => const Color(0xFFE91E63), // Pink
    };
  }

  /// Get cost factor (relative to distance/duration)
  /// Used for pricing calculations
  double get costMultiplier {
    return switch (this) {
      TransportMode.toto => 1.5,      // Ride-sharing premium
      TransportMode.ferry => 2.0,     // Water transport premium
      TransportMode.bus => 0.5,       // Budget public transport
      TransportMode.train => 0.8,     // Standard rail
      TransportMode.localTrain => 0.6, // Local transit discount
      TransportMode.metro => 0.4,     // Cheapest option
    };
  }
}
