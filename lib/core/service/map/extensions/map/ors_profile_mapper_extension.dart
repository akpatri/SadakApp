import 'package:sadak/core/model/map/transport_file_enum.dart';

extension ORSProfileMapper on TransportProfile {
  String toORSProfile() {
    switch (this) {
      case TransportProfile.driving:
        return 'driving-car';
      case TransportProfile.cycling:
      case TransportProfile.bikeSharing:
        return 'cycling-regular';
      case TransportProfile.walking:
        return 'foot-walking';
      case TransportProfile.bus:
      case TransportProfile.train:
        return 'driving-car'; // fallback
       case TransportProfile.ferry:
        return 'driving-car';
    }
  }
}
