import 'package:equatable/equatable.dart';

class RouteComment extends Equatable {
  final String id;
  final String routeId;
  final String userId;
  final String message;
  final DateTime createdAt;

  const RouteComment({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.message,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, routeId, userId, message];
}
