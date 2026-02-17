import 'package:open_route_service/open_route_service.dart';

extension GeoJsonFeatureCopy on GeoJsonFeature {
  GeoJsonFeature copyWith({
    String? type,
    Map<String, dynamic>? properties,
    GeoJsonFeatureGeometry? geometry,
    List<ORSCoordinate>? bbox,
  }) {
    return GeoJsonFeature(
      type: type ?? this.type,
      properties: properties ?? this.properties,
      geometry: geometry ?? this.geometry,
      bbox: bbox ?? this.bbox,
    );
  }
}
