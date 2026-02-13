
import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_route.dart';
import 'package:sadak/core/model/route/route_badge_enum.dart';
import 'package:sadak/core/model/route/route_source_type_enum.dart';
import 'package:sadak/core/model/route/route_vote_summery.dart';


/// ===============================================================
/// COMMUNITY ROUTE MODEL
/// Wraps MapRoute with community metadata
/// ===============================================================

class CommunityRoute {
  final String id;
  final String ownerId;
  final String ownerName;

  final RouteSourceType sourceType;

  /// Pure routing domain
  final MapRoute route;

  /// Optional notes / tips from user
  final String? notes;

  final RouteVoteSummary votes;
  final List<RouteBadge> badges;

  final DateTime createdAt;

  const CommunityRoute({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.sourceType,
    required this.route,
    this.notes,
    required this.votes,
    required this.badges,
    required this.createdAt,
  });
}


