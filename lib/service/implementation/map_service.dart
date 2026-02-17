import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/model/geo_json_property_model.dart';
import 'package:sadak/service/implementation/ors_map_service_impl.dart';
import 'package:sadak/service/interface/map/i_location_service.dart';
import 'package:sadak/service/interface/map/i_pricing_service.dart';
import 'package:geolocator/geolocator.dart';

class MapService extends ORSMapService
    implements ILocationService, IPricingService {
  MapService({required super.openRouteServiceClient});
  @override
  Future<PoisData> getCurrentPosition() async {
    try {
      // 1️⃣ Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException();
      }

      // 2️⃣ Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permission permanently denied");
      }

      // 3️⃣ Get current position with timeout protection
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: LocationSettings(
              accuracy: kIsWeb
                  ? LocationAccuracy.medium
                  : LocationAccuracy.high,
              distanceFilter: 0,
            ),
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException("Location request timeout"),
          );

      // 4️⃣ Create reusable coordinate
      final coordinate = ORSCoordinate(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // 5️⃣ Build geometry
      final geometry = GeoJsonFeatureGeometry(
        type: "Point",
        internalType: GsonFeatureGeometryCoordinatesType.single,
        coordinates: [
          [coordinate],
        ],
      );

      // 6️⃣ Build enriched feature properties (CENTRALIZED + FUTURE SAFE)
      final properties = GeoJsonProperty(
        id: "source",
        type: "source", // IMPORTANT
        isVisible: true,
        label: "Current Location",
        extra: {
          "accuracy": position.accuracy,
          "altitude": position.altitude,
          "speed": position.speed,
          "heading": position.heading,
          "timestamp": position.timestamp.millisecondsSinceEpoch,
          "source": kIsWeb ? "browser_gps" : "device_gps",
        },
      ).toJson();

      final feature = GeoJsonFeature(
        type: "Feature",
        properties: properties,
        geometry: geometry,
      );

      // 7️⃣ Build information metadata
      final information = PoisInformation(
        attribution: kIsWeb ? "Browser GPS" : "Device GPS",
        version: "1.0.0",
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // 8️⃣ Return structured data
      return PoisData(
        bbox: [coordinate, coordinate],
        features: [feature],
        information: information,
      );
    } on TimeoutException {
      rethrow;
    } on LocationServiceDisabledException {
      rethrow;
    } catch (e) {
      throw Exception("Failed to get current location: $e");
    }
  }

  @override
  double calculate({
    required double distance,
    required double duration,
    required ORSProfile profile,
  }) {
    final distanceKm = distance / 1000;
    final durationMin = duration / 60;

    switch (profile) {
      case ORSProfile.drivingCar:
        return durationMin * 0.5; // low effort

      case ORSProfile.drivingHgv:
        return durationMin * 0.7;

      case ORSProfile.cyclingRoad:
        return distanceKm * 3;

      case ORSProfile.cyclingMountain:
        return distanceKm * 5;

      case ORSProfile.cyclingElectric:
        return distanceKm * 2;

      case ORSProfile.footWalking:
        return durationMin * 2;

      case ORSProfile.footHiking:
        return durationMin * 3;

      case ORSProfile.wheelchair:
        return durationMin * 1.5;
    }
  }
}
