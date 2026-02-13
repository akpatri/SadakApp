import 'package:latlong2/latlong.dart';

/// ===============================================================
/// ROUTE SOURCE TYPE
/// ===============================================================

enum RouteSourceType {
  userSubmitted,
  gptSuggested,
  communityVerified,
}

/// ===============================================================
/// ROUTE BADGE
/// ===============================================================

enum RouteBadge {
  recommended,
  fastest,
  ecoFriendly,
  verified,
}

/// ===============================================================
/// ROUTE VOTE SUMMARY
/// ===============================================================

class RouteVoteSummary {
  final int upVotes;
  final int downVotes;

  const RouteVoteSummary({
    required this.upVotes,
    required this.downVotes,
  });

  int get score => upVotes - downVotes;
}

/// ===============================================================
/// ROUTE COMMENT
/// ===============================================================

class RouteComment {
  final String id;
  final String routeId;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;

  const RouteComment({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
  });
}

/// ===============================================================
/// COMMUNITY ROUTE MODEL
/// Extends your MapRoute with community metadata
/// ===============================================================

class CommunityRoute {
  final String id;
  final String ownerId;
  final String ownerName;

  final RouteSourceType sourceType;

  final double totalDistanceMeters;
  final double totalDurationSeconds;
  final double totalCost;

  final List<dynamic> segments; 
  // Use MapRouteSegment if imported from map domain

  final List<LatLng> geometry;

  final RouteVoteSummary votes;
  final List<RouteBadge> badges;

  final DateTime createdAt;

  const CommunityRoute({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.sourceType,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
    required this.totalCost,
    required this.segments,
    required this.geometry,
    required this.votes,
    required this.badges,
    required this.createdAt,
  });
}

/// ===============================================================
/// USER CONTRIBUTION SUMMARY (Sidebar Support)
/// ===============================================================

class UserContributionSummary {
  final int totalRoutes;
  final int totalComments;
  final List<String> recentRouteTitles;
  final List<String> recentComments;

  const UserContributionSummary({
    required this.totalRoutes,
    required this.totalComments,
    required this.recentRouteTitles,
    required this.recentComments,
  });
}

/// ===============================================================
/// COMMUNITY ROUTE SERVICE CONTRACT
/// ===============================================================

abstract class ICommunityRouteService {
  // =============================================================
  // ROUTE CRUD
  // =============================================================

  /// Submit new multi-segment route
  Future<CommunityRoute> submitRoute({
    required String ownerId,
    required String ownerName,
    required RouteSourceType sourceType,
    required double totalDistanceMeters,
    required double totalDurationSeconds,
    required double totalCost,
    required List<dynamic> segments,
    required List<LatLng> geometry,
    String? notes,
  });

  /// Delete route (Owner only)
  Future<void> deleteRoute({
    required String routeId,
    required String requesterId,
  });

  /// Fetch routes for a specific area
  Future<List<CommunityRoute>> fetchRoutes({
    required LatLng start,
    required LatLng end,
  });

  /// Fetch single route details
  Future<CommunityRoute?> getRouteById(String routeId);

  // =============================================================
  // VOTING
  // =============================================================

  Future<RouteVoteSummary> voteRoute({
    required String routeId,
    required String userId,
    required bool isUpVote,
  });

  Future<void> removeVote({
    required String routeId,
    required String userId,
  });

  // =============================================================
  // COMMENTS
  // =============================================================

  Future<List<RouteComment>> fetchComments(String routeId);

  Future<RouteComment> addComment({
    required String routeId,
    required String userId,
    required String userName,
    required String message,
  });

  /// Authenticated user can delete ONLY their own comment
  Future<void> deleteComment({
    required String commentId,
    required String requesterId,
  });

  // =============================================================
  // USER SIDEBAR SUPPORT
  // =============================================================

  Future<UserContributionSummary> getUserContributionSummary(
    String userId,
  );

  Future<List<CommunityRoute>> getUserRoutes(String userId);

  Future<List<RouteComment>> getUserComments(String userId);

  // =============================================================
  // ADMIN / VERIFICATION
  // =============================================================

  Future<void> verifyRoute({
    required String routeId,
    required String verifierId,
  });
}
