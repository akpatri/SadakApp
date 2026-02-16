import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/core/app_config.dart';
import 'package:sadak/model/view/location_suggestion_model.dart';
import 'package:sadak/service/implementation/map_service.dart';
import 'package:sadak/service/interface/map/ors/i_ors_direction_service.dart';
import 'package:sadak/service/interface/map/i_location_service.dart';
import 'package:sadak/service/interface/map/i_pricing_service.dart';
import 'package:sadak/service/interface/map/ors/i_ors_elevattion_service.dart';
import 'package:sadak/service/interface/map/ors/i_ors_geo_code_service.dart';
import 'package:sadak/service/interface/map/ors/i_ors_isochrone_service.dart';
import 'package:sadak/service/interface/map/ors/i_ors_positions_service.dart';
import 'package:sadak/service/interface/map/ors/i_orx_matrix_service.dart';
import 'package:sadak/service/interface/map/ors/i_orx_optimization_service.dart';
import 'package:sadak/view_model/location_autocomplete_view_model.dart';
import 'package:sadak/view_model/map_veiw_model.dart';

final orsClientProvider = Provider<OpenRouteService>((ref) {
  return OpenRouteService(apiKey: AppConfig.ors_api_key);
});

final mapServiceProvider = Provider<MapService>((ref) {
  return MapService(openRouteServiceClient: ref.read(orsClientProvider));
});

final directionsServiceProvider = Provider<IORSDirection>((ref) {
  return ref.read(mapServiceProvider);
});

final elevationServiceProvider = Provider<IORSElevattion>((ref) {
  return ref.read(mapServiceProvider);
});

final geoCodingServiceProvider = Provider<IORSGeocode>((ref) {
  return ref.read(mapServiceProvider);
});

final isochroneCodingServiceProvider = Provider<IORSIsochrones>((ref) {
  return ref.read(mapServiceProvider);
});

final postionServiceProvider = Provider<IORSPois>((ref) {
  return ref.read(mapServiceProvider);
});

final matrixServiceProvider = Provider<IORSMatrix>((ref) {
  return ref.read(mapServiceProvider);
});

final optizationServiceProvider = Provider<IORSOptimization>((ref) {
  return ref.read(mapServiceProvider);
});

final locationServiceProvider = Provider<ILocationService>((ref) {
  return ref.read(mapServiceProvider);
});

final pricingServiceProvider = Provider<IPricingService>((ref) {
  return ref.read(mapServiceProvider);
});

final locationAutocompleteProvider =
    AsyncNotifierProvider<LocationAutocompleteNotifier,
        List<LocationSuggestion>>(
  LocationAutocompleteNotifier.new,
);

final mapViewModelProvider =
    AsyncNotifierProvider<MapViewModel, GeoJsonFeatureCollection>(
      MapViewModel.new,
    );