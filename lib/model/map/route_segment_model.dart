import 'package:equatable/equatable.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/model/map/transport_mode.dart';

class RouteSegment extends Equatable {
  final DirectionRouteData ors;
  final ORSProfile profile;
  final double price;
  final TransportMode transportMode;          // NEW
  final int? estimatedPassengers;             // NEW
  final bool availability;                    // NEW - is this transport available?

  const RouteSegment({
    required this.ors,
    required this.profile,
    required this.price,
    required this.transportMode,
    this.estimatedPassengers,
    this.availability = true,
  });

  double get distance => ors.summary.distance;

  double get duration => ors.summary.duration;

  @override
  List<Object?> get props => [
    ors,
    profile,
    price,
    transportMode,
    estimatedPassengers,
    availability,
  ];

  /// Create copy with modified fields
  RouteSegment copyWith({
    DirectionRouteData? ors,
    ORSProfile? profile,
    double? price,
    TransportMode? transportMode,
    int? estimatedPassengers,
    bool? availability,
  }) {
    return RouteSegment(
      ors: ors ?? this.ors,
      profile: profile ?? this.profile,
      price: price ?? this.price,
      transportMode: transportMode ?? this.transportMode,
      estimatedPassengers: estimatedPassengers ?? this.estimatedPassengers,
      availability: availability ?? this.availability,
    );
  }
}

