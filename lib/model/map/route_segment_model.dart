import 'package:equatable/equatable.dart';
import 'package:open_route_service/open_route_service.dart';

class RouteSegment extends Equatable {
  final DirectionRouteData ors;
  final ORSProfile profile;
  final double price;

  const RouteSegment({
    required this.ors,
    required this.profile,
    required this.price,
  });

  double get distance => ors.summary.distance;

  double get duration => ors.summary.duration;

  @override
  List<Object?> get props => [ors, profile, price];
}
