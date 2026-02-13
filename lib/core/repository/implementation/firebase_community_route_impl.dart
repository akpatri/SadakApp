import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_route.dart';
import 'package:sadak/core/model/map/map_route_segment.dart';
import 'package:sadak/core/model/map/transport_file_enum.dart';
import 'package:sadak/core/model/route/community_route_model.dart';
import 'package:sadak/core/model/route/route_badge_enum.dart';
import 'package:sadak/core/model/route/route_comment_model.dart';
import 'package:sadak/core/model/route/route_source_type_enum.dart';
import 'package:sadak/core/model/route/route_vote_summery.dart';
import 'package:sadak/core/model/route/user_contribution_summery_model.dart';
import 'package:sadak/core/repository/interface/i_community_route_repository.dart';

class FirebaseCommunityRouteRepository implements ICommunityRouteRepository {
    final FirebaseFirestore _firestore;
    FirebaseCommunityRouteRepository(this._firestore);
  
  @override
  Future<RouteComment> addComment({
    required String routeId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    if (routeId.trim().isEmpty) {
      throw ArgumentError('routeId cannot be empty');
    }

    if (userId.trim().isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }

    if (userName.trim().isEmpty) {
      throw ArgumentError('userName cannot be empty');
    }

    if (message.trim().isEmpty) {
      throw ArgumentError('message cannot be empty');
    }

    final routeRef = _firestore.collection('community_routes').doc(routeId);

    final routeSnapshot = await routeRef.get();

    if (!routeSnapshot.exists) {
      throw Exception('Route not found');
    }

    final commentRef = routeRef.collection('comments').doc();

    final createdAt = DateTime.now().toUtc();

    final comment = RouteComment(
      id: commentRef.id,
      routeId: routeId,
      userId: userId,
      userName: userName,
      message: message.trim(),
      createdAt: createdAt,
    );

    await commentRef.set({
      'id': comment.id,
      'routeId': routeId,
      'userId': userId,
      'userName': userName,
      'message': comment.message,
      'createdAt': createdAt,
    });

    return comment;
  }

  @override
  Future<void> deleteComment({
    required String commentId,
    required String requesterId,
  }) async {
    if (commentId.trim().isEmpty) {
      throw ArgumentError('commentId cannot be empty');
    }

    if (requesterId.trim().isEmpty) {
      throw ArgumentError('requesterId cannot be empty');
    }

    // Find the comment using collection group query
    final querySnapshot = await _firestore
        .collectionGroup('comments')
        .where('id', isEqualTo: commentId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Comment not found');
    }

    final doc = querySnapshot.docs.first;
    final data = doc.data();

    // Only comment owner can delete
    if (data['userId'] != requesterId) {
      throw Exception('Unauthorized: cannot delete this comment');
    }

    await doc.reference.delete();
  }

  @override
  Future<void> deleteRoute({
    required String routeId,
    required String requesterId,
  }) async {
    if (routeId.trim().isEmpty) {
      throw ArgumentError('routeId cannot be empty');
    }

    if (requesterId.trim().isEmpty) {
      throw ArgumentError('requesterId cannot be empty');
    }

    final routeRef = _firestore.collection('community_routes').doc(routeId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(routeRef);

      if (!snapshot.exists) {
        throw Exception('Route not found');
      }

      final data = snapshot.data() as Map<String, dynamic>;

      if (data['ownerId'] != requesterId) {
        throw Exception('Unauthorized: only owner can delete route');
      }

      transaction.delete(routeRef);
    });

    // ==========================================================
    // Delete votes subcollection (outside transaction)
    // ==========================================================

    final votesSnapshot = await routeRef.collection('votes').get();

    for (final doc in votesSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<List<RouteComment>> fetchComments(String routeId) async {
    if (routeId.trim().isEmpty) {
      throw ArgumentError('routeId cannot be empty');
    }

    final routeRef = _firestore.collection('community_routes').doc(routeId);

    final snapshot = await routeRef
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .get();

    final List<RouteComment> comments = [];

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();

        comments.add(
          RouteComment(
            id: data['id'],
            routeId: data['routeId'],
            userId: data['userId'],
            userName: data['userName'],
            message: data['message'],
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          ),
        );
      } catch (_) {
        // Skip malformed comment safely
        continue;
      }
    }

    return comments;
  }

  @override
  Future<List<CommunityRoute>> fetchRoutes({
    required LatLng start,
    required LatLng end,
  }) async {
    final snapshot = await _firestore.collection('community_routes').get();

    final List<CommunityRoute> routes = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      try {
        final routeMap = data['route'] as Map<String, dynamic>;

        // Deserialize segments
        final segments = (routeMap['segments'] as List).map((s) {
          return MapRouteSegment(
            profile: TransportProfile.fromString(s['profile']),
            distanceMeters: (s['distanceMeters'] as num).toDouble(),
            durationSeconds: (s['durationSeconds'] as num).toDouble(),
            cost: (s['cost'] as num).toDouble(),
            geometry: (s['geometry'] as List)
                .map<LatLng>(
                  (p) => LatLng(
                    (p['lat'] as num).toDouble(),
                    (p['lng'] as num).toDouble(),
                  ),
                )
                .toList(),
          );
        }).toList();

        // Deserialize full geometry
        final fullGeometry = (routeMap['fullGeometry'] as List)
            .map<LatLng>(
              (p) => LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              ),
            )
            .toList();

        final mapRoute = MapRoute(
          totalDistanceMeters: (routeMap['totalDistanceMeters'] as num)
              .toDouble(),
          totalDurationSeconds: (routeMap['totalDurationSeconds'] as num)
              .toDouble(),
          totalCost: (routeMap['totalCost'] as num).toDouble(),
          segments: segments,
          fullGeometry: fullGeometry,
        );

        final votesMap = Map<String, dynamic>.from(data['votes']);

        final communityRoute = CommunityRoute(
          id: data['id'],
          ownerId: data['ownerId'],
          ownerName: data['ownerName'],
          sourceType: RouteSourceType.values.byName(data['sourceType']),
          route: mapRoute,
          notes: data['notes'],
          votes: RouteVoteSummary(
            upVotes: votesMap['upVotes'] ?? 0,
            downVotes: votesMap['downVotes'] ?? 0,
          ),
          badges: (data['badges'] as List)
              .map<RouteBadge>((b) => RouteBadge.values.byName(b))
              .toList(),
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );

        routes.add(communityRoute);
      } catch (_) {
        // Skip malformed documents safely
        continue;
      }
    }

    return routes;
  }

  @override
  Future<CommunityRoute?> getRouteById(String routeId) async {
    if (routeId.trim().isEmpty) {
      throw ArgumentError('routeId cannot be empty');
    }

    final docRef = _firestore.collection('community_routes').doc(routeId);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data() as Map<String, dynamic>;
    final routeMap = data['route'] as Map<String, dynamic>;

    // Deserialize segments
    final segments = (routeMap['segments'] as List).map((s) {
      return MapRouteSegment(
        profile: TransportProfile.fromString(s['profile']),
        distanceMeters: (s['distanceMeters'] as num).toDouble(),
        durationSeconds: (s['durationSeconds'] as num).toDouble(),
        cost: (s['cost'] as num).toDouble(),
        geometry: (s['geometry'] as List)
            .map<LatLng>(
              (p) => LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              ),
            )
            .toList(),
      );
    }).toList();

    // Deserialize full geometry
    final fullGeometry = (routeMap['fullGeometry'] as List)
        .map<LatLng>(
          (p) => LatLng(
            (p['lat'] as num).toDouble(),
            (p['lng'] as num).toDouble(),
          ),
        )
        .toList();

    final mapRoute = MapRoute(
      totalDistanceMeters: (routeMap['totalDistanceMeters'] as num).toDouble(),
      totalDurationSeconds: (routeMap['totalDurationSeconds'] as num)
          .toDouble(),
      totalCost: (routeMap['totalCost'] as num).toDouble(),
      segments: segments,
      fullGeometry: fullGeometry,
    );

    final votesMap = Map<String, dynamic>.from(data['votes']);

    return CommunityRoute(
      id: data['id'],
      ownerId: data['ownerId'],
      ownerName: data['ownerName'],
      sourceType: RouteSourceType.values.byName(data['sourceType']),
      route: mapRoute,
      notes: data['notes'],
      votes: RouteVoteSummary(
        upVotes: votesMap['upVotes'] ?? 0,
        downVotes: votesMap['downVotes'] ?? 0,
      ),
      badges: (data['badges'] as List)
          .map<RouteBadge>((b) => RouteBadge.values.byName(b))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  Future<List<RouteComment>> getUserComments(String userId) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }

    final snapshot = await _firestore
        .collectionGroup('comments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    final List<RouteComment> comments = [];

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();

        comments.add(
          RouteComment(
            id: data['id'],
            routeId: data['routeId'],
            userId: data['userId'],
            userName: data['userName'],
            message: data['message'],
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          ),
        );
      } catch (_) {
        // Skip malformed documents safely
        continue;
      }
    }

    return comments;
  }

  @override
  Future<UserContributionSummary> getUserContributionSummary(
    String userId,
  ) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }

    // 1️⃣ Fetch user's routes
    final routesSnapshot = await _firestore
        .collection('community_routes')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    final totalRoutes = routesSnapshot.size;

    final recentRouteTitles = routesSnapshot.docs
        .map((doc) => doc.data()['notes'] as String? ?? 'Untitled Route')
        .toList();

    // 2️⃣ Fetch user's comments
    final commentsSnapshot = await _firestore
        .collectionGroup('comments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    final totalComments = commentsSnapshot.size;

    final recentComments = commentsSnapshot.docs
        .map((doc) => doc.data()['message'] as String)
        .toList();

    return UserContributionSummary(
      totalRoutes: totalRoutes,
      totalComments: totalComments,
      recentRouteTitles: recentRouteTitles,
      recentComments: recentComments,
    );
  }

  @override
  Future<List<CommunityRoute>> getUserRoutes(String userId) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }

    final snapshot = await _firestore
        .collection('community_routes')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    final List<CommunityRoute> routes = [];

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        final routeMap = data['route'] as Map<String, dynamic>;

        // Deserialize segments
        final segments = (routeMap['segments'] as List).map((s) {
          return MapRouteSegment(
            profile: TransportProfile.fromString(s['profile']),
            distanceMeters: (s['distanceMeters'] as num).toDouble(),
            durationSeconds: (s['durationSeconds'] as num).toDouble(),
            cost: (s['cost'] as num).toDouble(),
            geometry: (s['geometry'] as List)
                .map<LatLng>(
                  (p) => LatLng(
                    (p['lat'] as num).toDouble(),
                    (p['lng'] as num).toDouble(),
                  ),
                )
                .toList(),
          );
        }).toList();

        final fullGeometry = (routeMap['fullGeometry'] as List)
            .map<LatLng>(
              (p) => LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              ),
            )
            .toList();

        final mapRoute = MapRoute(
          totalDistanceMeters: (routeMap['totalDistanceMeters'] as num)
              .toDouble(),
          totalDurationSeconds: (routeMap['totalDurationSeconds'] as num)
              .toDouble(),
          totalCost: (routeMap['totalCost'] as num).toDouble(),
          segments: segments,
          fullGeometry: fullGeometry,
        );

        final votesMap = Map<String, dynamic>.from(data['votes']);

        routes.add(
          CommunityRoute(
            id: data['id'],
            ownerId: data['ownerId'],
            ownerName: data['ownerName'],
            sourceType: RouteSourceType.values.byName(data['sourceType']),
            route: mapRoute,
            notes: data['notes'],
            votes: RouteVoteSummary(
              upVotes: votesMap['upVotes'] ?? 0,
              downVotes: votesMap['downVotes'] ?? 0,
            ),
            badges: (data['badges'] as List)
                .map<RouteBadge>((b) => RouteBadge.values.byName(b))
                .toList(),
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          ),
        );
      } catch (_) {
        // Skip malformed documents
        continue;
      }
    }

    return routes;
  }

  @override
  Future<void> removeVote({
    required String routeId,
    required String userId,
  }) async {
    if (routeId.trim().isEmpty) {
      throw ArgumentError('routeId cannot be empty');
    }

    if (userId.trim().isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }

    final routeRef = _firestore.collection('community_routes').doc(routeId);
    final voteRef = routeRef.collection('votes').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final routeSnapshot = await transaction.get(routeRef);

      if (!routeSnapshot.exists) {
        throw Exception('Route not found');
      }

      final voteSnapshot = await transaction.get(voteRef);

      // No vote exists → nothing to remove
      if (!voteSnapshot.exists) {
        return;
      }

      final routeData = routeSnapshot.data() as Map<String, dynamic>;
      final votesMap = Map<String, dynamic>.from(routeData['votes']);

      int upVotes = votesMap['upVotes'] ?? 0;
      int downVotes = votesMap['downVotes'] ?? 0;

      final existingIsUpVote =
          (voteSnapshot.data() as Map<String, dynamic>)['isUpVote'];

      // Decrement safely
      if (existingIsUpVote == true) {
        upVotes = upVotes > 0 ? upVotes - 1 : 0;
      } else {
        downVotes = downVotes > 0 ? downVotes - 1 : 0;
      }

      // Delete vote document
      transaction.delete(voteRef);

      // Update counters
      transaction.update(routeRef, {
        'votes': {'upVotes': upVotes, 'downVotes': downVotes},
      });
    });
  }

  @override
  Future<CommunityRoute> submitRoute({
    required String ownerId,
    required String ownerName,
    required RouteSourceType sourceType,
    required MapRoute route,
    String? notes,
  }) async {
    // ===============================
    // Basic Validation
    // ===============================
    if (ownerId.trim().isEmpty) {
      throw ArgumentError('ownerId cannot be empty');
    }

    if (ownerName.trim().isEmpty) {
      throw ArgumentError('ownerName cannot be empty');
    }

    if (route.segments.isEmpty) {
      throw ArgumentError('Route must contain at least one segment');
    }

    // ===============================
    // Create Firestore Document Ref  impl in provider
    // ===============================
    final docRef = _firestore.collection('community_routes').doc();

    final createdAt = DateTime.now().toUtc();

    // ===============================
    // Build Domain Object
    // ===============================
    final communityRoute = CommunityRoute(
      id: docRef.id,
      ownerId: ownerId,
      ownerName: ownerName,
      sourceType: sourceType,
      route: route,
      notes: notes?.trim(),
      votes: const RouteVoteSummary(upVotes: 0, downVotes: 0),
      badges: const [],
      createdAt: createdAt,
    );

    // ===============================
    // Persist to Firestore
    // ===============================
    await docRef.set({
      'id': communityRoute.id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'sourceType': sourceType.name,
      'notes': communityRoute.notes,
      'createdAt': createdAt,
      'votes': {'upVotes': 0, 'downVotes': 0},
      'badges': [],
      'route': {
        'totalDistanceMeters': route.totalDistanceMeters,
        'totalDurationSeconds': route.totalDurationSeconds,
        'totalCost': route.totalCost,
        'segments': route.segments.map((s) {
          return {
            'profile': s.profile.name,
            'distanceMeters': s.distanceMeters,
            'durationSeconds': s.durationSeconds,
            'cost': s.cost,
            'geometry': s.geometry
                .map((p) => {'lat': p.latitude, 'lng': p.longitude})
                .toList(),
          };
        }).toList(),
        'fullGeometry': route.fullGeometry
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
      },
    });

    return communityRoute;
  }

  @override
  Future<void> verifyRoute({
    required String routeId,
    required String verifierId,
  }) async {
    if (routeId.trim().isEmpty) {
      throw ArgumentError('routeId cannot be empty');
    }

    if (verifierId.trim().isEmpty) {
      throw ArgumentError('verifierId cannot be empty');
    }

    final docRef = _firestore.collection('community_routes').doc(routeId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Route not found');
      }

      final data = snapshot.data() as Map<String, dynamic>;

      final List<dynamic> badgesRaw = data['badges'] ?? [];
      final List<String> badges = List<String>.from(badgesRaw);

      // Add verified badge if not already present
      if (!badges.contains(RouteBadge.verified.name)) {
        badges.add(RouteBadge.verified.name);
      }

      transaction.update(docRef, {
        'badges': badges,
        'sourceType': RouteSourceType.communityVerified.name,
        'verifiedBy': verifierId,
        'verifiedAt': DateTime.now().toUtc(),
      });
    });
  }

  @override
  Future<RouteVoteSummary> voteRoute({
    required String routeId,
    required String userId,
    required bool isUpVote,
  }) async {
    if (routeId.trim().isEmpty) {
      throw ArgumentError('routeId cannot be empty');
    }

    if (userId.trim().isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }

    final routeRef = _firestore.collection('community_routes').doc(routeId);
    final voteRef = routeRef.collection('votes').doc(userId);

    return await _firestore.runTransaction<RouteVoteSummary>((
      transaction,
    ) async {
      final routeSnapshot = await transaction.get(routeRef);

      if (!routeSnapshot.exists) {
        throw Exception('Route not found');
      }

      final routeData = routeSnapshot.data() as Map<String, dynamic>;
      final votesMap = Map<String, dynamic>.from(routeData['votes']);

      int upVotes = votesMap['upVotes'] ?? 0;
      int downVotes = votesMap['downVotes'] ?? 0;

      final existingVoteSnapshot = await transaction.get(voteRef);

      // ==========================================================
      // CASE 1: No previous vote
      // ==========================================================
      if (!existingVoteSnapshot.exists) {
        if (isUpVote) {
          upVotes++;
        } else {
          downVotes++;
        }

        transaction.set(voteRef, {
          'isUpVote': isUpVote,
          'votedAt': DateTime.now().toUtc(),
        });
      }
      // ==========================================================
      // CASE 2: Existing vote
      // ==========================================================
      else {
        final existingIsUpVote =
            (existingVoteSnapshot.data() as Map<String, dynamic>)['isUpVote'];

        // If same vote → do nothing
        if (existingIsUpVote == isUpVote) {
          return RouteVoteSummary(upVotes: upVotes, downVotes: downVotes);
        }

        // If switching vote
        if (existingIsUpVote == true) {
          upVotes--;
          downVotes++;
        } else {
          downVotes--;
          upVotes++;
        }

        transaction.update(voteRef, {
          'isUpVote': isUpVote,
          'votedAt': DateTime.now().toUtc(),
        });
      }

      // Update route vote counters
      transaction.update(routeRef, {
        'votes': {'upVotes': upVotes, 'downVotes': downVotes},
      });

      return RouteVoteSummary(upVotes: upVotes, downVotes: downVotes);
    });
  }
}
