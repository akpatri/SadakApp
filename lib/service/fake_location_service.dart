import 'package:latlong2/latlong.dart';

import 'i_location_service.dart';

class FakeLocationService implements ILocationService {
  @override
  Future<LatLng> getCurrentLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    return const LatLng(12.9716, 77.5946);
  }
}
