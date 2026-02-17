import 'package:flutter/foundation.dart';

/// ===============================================================
///  SINGLE SOURCE OF TRUTH PROPERTY MODEL
///  Used inside GeoJsonFeature.properties (Map<String, dynamic>)
/// ===============================================================

@immutable
class GeoJsonProperty {
  /// -------------------------------------------------------------
  /// CORE IDENTITY
  /// -------------------------------------------------------------

  /// Unique feature id
  final String id;

  /// Allowed values:
  /// user_location
  /// source
  /// destination
  /// route
  /// route_segment
  /// segment_marker
  /// boarding_point
  /// waypoint
  final String type;

  /// Groups features belonging to same route
  final String? routeId;

  /// Used for segment_marker / boarding_point
  final String? parentSegmentId;

  /// -------------------------------------------------------------
  /// VISIBILITY & STATE CONTROL
  /// -------------------------------------------------------------

  final bool isVisible;
  final bool isSelected;
  final bool isEditable;

  /// -------------------------------------------------------------
  /// ROUTE LEVEL DATA (type == route)
  /// -------------------------------------------------------------

  /// gpt | community | official
  final String? routeSource;

  final int? totalDuration;     // minutes
  final double? totalDistance;  // km
  final double? totalCost;      // currency

  final int? upVotes;
  final int? downVotes;
  final int? verifiedCount;

  /// Optional ranking score (AI / backend scoring)
  final double? score;

  /// -------------------------------------------------------------
  /// SEGMENT LEVEL DATA (type == route_segment)
  /// -------------------------------------------------------------

  final int? segmentIndex;
  final String? transportMode;  // walk | bus | train | cab
  final int? segmentDuration;

  /// -------------------------------------------------------------
  /// DISPLAY DATA
  /// -------------------------------------------------------------

  final String? label;

  /// -------------------------------------------------------------
  /// SAFE EXTENSION SLOT
  /// -------------------------------------------------------------

  final Map<String, dynamic>? extra;

  const GeoJsonProperty({
    required this.id,
    required this.type,
    this.routeId,
    this.parentSegmentId,
    this.isVisible = true,
    this.isSelected = false,
    this.isEditable = false,
    this.routeSource,
    this.totalDuration,
    this.totalDistance,
    this.totalCost,
    this.upVotes,
    this.downVotes,
    this.verifiedCount,
    this.score,
    this.segmentIndex,
    this.transportMode,
    this.segmentDuration,
    this.label,
    this.extra,
  });

  /// ===============================================================
  /// SAFE DYNAMIC CONVERSION (GLOBAL ENTRY POINT)
  /// ===============================================================

  /// Converts ANY dynamic value into GeoJsonProperty safely
  static GeoJsonProperty? fromDynamic(dynamic raw) {
    if (raw == null) return null;

    if (raw is GeoJsonProperty) {
      return raw;
    }

    if (raw is Map) {
      return GeoJsonProperty.fromJson(
        Map<String, dynamic>.from(raw),
      );
    }

    return null;
  }

  /// ===============================================================
  /// COMPUTED HELPERS
  /// ===============================================================

  bool get isRoute => type == "route";
  bool get isSegment => type == "route_segment";
  bool get isUserLocation => type == "user_location";

  int get netVotes => (upVotes ?? 0) - (downVotes ?? 0);

  bool get isCommunityRoute => routeSource == "community";
  bool get isGptRoute => routeSource == "gpt";
  bool get isOfficialRoute => routeSource == "official";

  /// ===============================================================
  /// COPY WITH (IMMUTABLE UPDATE)
  /// ===============================================================

  GeoJsonProperty copyWith({
    bool? isVisible,
    bool? isSelected,
    bool? isEditable,
    int? upVotes,
    int? downVotes,
    double? score,
    Map<String, dynamic>? extra,
  }) {
    return GeoJsonProperty(
      id: id,
      type: type,
      routeId: routeId,
      parentSegmentId: parentSegmentId,
      isVisible: isVisible ?? this.isVisible,
      isSelected: isSelected ?? this.isSelected,
      isEditable: isEditable ?? this.isEditable,
      routeSource: routeSource,
      totalDuration: totalDuration,
      totalDistance: totalDistance,
      totalCost: totalCost,
      upVotes: upVotes ?? this.upVotes,
      downVotes: downVotes ?? this.downVotes,
      verifiedCount: verifiedCount,
      score: score ?? this.score,
      segmentIndex: segmentIndex,
      transportMode: transportMode,
      segmentDuration: segmentDuration,
      label: label,
      extra: extra ?? this.extra,
    );
  }

  /// ===============================================================
  /// SERIALIZATION (Map <-> Model)
  /// ===============================================================

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type,
      "routeId": routeId,
      "parentSegmentId": parentSegmentId,
      "isVisible": isVisible,
      "isSelected": isSelected,
      "isEditable": isEditable,
      "routeSource": routeSource,
      "totalDuration": totalDuration,
      "totalDistance": totalDistance,
      "totalCost": totalCost,
      "upVotes": upVotes,
      "downVotes": downVotes,
      "verifiedCount": verifiedCount,
      "score": score,
      "segmentIndex": segmentIndex,
      "transportMode": transportMode,
      "segmentDuration": segmentDuration,
      "label": label,
      "extra": extra,
    };
  }

  factory GeoJsonProperty.fromJson(Map<String, dynamic> json) {
    return GeoJsonProperty(
      id: json["id"] ?? "",
      type: json["type"] ?? "",
      routeId: json["routeId"],
      parentSegmentId: json["parentSegmentId"],
      isVisible: json["isVisible"] ?? true,
      isSelected: json["isSelected"] ?? false,
      isEditable: json["isEditable"] ?? false,
      routeSource: json["routeSource"],
      totalDuration: json["totalDuration"],
      totalDistance: (json["totalDistance"] as num?)?.toDouble(),
      totalCost: (json["totalCost"] as num?)?.toDouble(),
      upVotes: json["upVotes"],
      downVotes: json["downVotes"],
      verifiedCount: json["verifiedCount"],
      score: (json["score"] as num?)?.toDouble(),
      segmentIndex: json["segmentIndex"],
      transportMode: json["transportMode"],
      segmentDuration: json["segmentDuration"],
      label: json["label"],
      extra: json["extra"] is Map
          ? Map<String, dynamic>.from(json["extra"])
          : null,
    );
  }

  /// ===============================================================
  /// PURE ROUTE STATE LOGIC (ARCHITECTURE SAFE)
  /// ===============================================================

  static List<GeoJsonProperty> selectRoute(
    List<GeoJsonProperty> properties,
    String selectedRouteId,
  ) {
    return properties.map((p) {
      if (p.isRoute) {
        final isTarget = p.routeId == selectedRouteId;
        return p.copyWith(
          isVisible: isTarget,
          isSelected: isTarget,
        );
      }

      if (p.isSegment) {
        return p.copyWith(
          isVisible: p.routeId == selectedRouteId,
        );
      }

      return p;
    }).toList();
  }

  static List<GeoJsonProperty> enterEditMode(
    List<GeoJsonProperty> properties,
    String routeId,
  ) {
    return properties.map((p) {
      if (p.routeId == routeId) {
        return p.copyWith(isEditable: true);
      }
      return p;
    }).toList();
  }
}
