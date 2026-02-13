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