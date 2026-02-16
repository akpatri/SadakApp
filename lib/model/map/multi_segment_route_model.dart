import 'package:equatable/equatable.dart';
import 'package:sadak/model/map/route_badge.dart';
import 'package:sadak/model/map/route_segment_model.dart';
import 'package:sadak/model/map/route_source_enum.dart';

class MultiSegmentRoute extends Equatable {
  final String id;
  final List<RouteSegment> segments;
  final RouteSource source;
  final List<RouteBadge> badges;
  final String? createdBy;

  final double votingScore;
  final int votesCount;

  const MultiSegmentRoute({
    required this.id,
    required this.segments,
    required this.source,
    required this.badges,
    this.createdBy,
    this.votingScore = 0,
    this.votesCount = 0,
  });

  double get totalDistance =>
      segments.fold(0, (s, e) => s + e.distance);

  double get totalDuration =>
      segments.fold(0, (s, e) => s + e.duration);

  double get totalPrice =>
      segments.fold(0, (s, e) => s + e.price);

  @override
  List<Object?> get props => [id, segments];
}
