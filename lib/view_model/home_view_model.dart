import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../core/di/app_provider.dart';


class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final locationService =
        ref.read(locationServiceProvider);

    final current =
        await locationService.getCurrentLocation();

    return HomeState(
      source: current,
      destination: null,
    );
  }

  void setDestination(LatLng dest) {
    state = AsyncData(
      state.value!.copyWith(destination: dest),
    );
  }
}

class HomeState {
  final LatLng source;
  final LatLng? destination;

  HomeState({
    required this.source,
    required this.destination,
  });

  HomeState copyWith({
    LatLng? source,
    LatLng? destination,
  }) {
    return HomeState(
      source: source ?? this.source,
      destination: destination ?? this.destination,
    );
  }
}
