import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'i_location_service.dart';

class LocationService implements ILocationService {
  @override
  Future<LatLng> getCurrentLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception("Location service disabled");
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Permission permanently denied");
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }
}
