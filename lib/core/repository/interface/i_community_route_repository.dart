import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_route.dart';
import 'package:sadak/core/model/route/community_route_model.dart';
import 'package:sadak/core/model/route/route_comment_model.dart';
import 'package:sadak/core/model/route/route_source_type_enum.dart';
import 'package:sadak/core/model/route/route_vote_summery.dart';
import 'package:sadak/core/model/route/user_contribution_summery_model.dart';

/// ===============================================================
/// COMMUNITY ROUTE SERVICE CONTRACT
/// ===============================================================

abstract class ICommunityRouteRepository {
  // =============================================================
  // ROUTE CRUD
  // =============================================================

  /// Submit new multi-segment route
  Future<CommunityRoute> submitRoute({
    required String ownerId,
    required String ownerName,
    required RouteSourceType sourceType,
    required MapRoute route,
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

  Future<void> removeVote({required String routeId, required String userId});

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

  Future<UserContributionSummary> getUserContributionSummary(String userId);

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
