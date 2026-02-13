import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sadak/core/repository/implementation/firebase_community_route_impl.dart';
import 'package:sadak/core/repository/implementation/geocoding_service_impl.dart';
import 'package:sadak/core/repository/implementation/home_repository_impl.dart';
import 'package:sadak/core/repository/interface/i_community_route_repository.dart';
import 'package:sadak/core/repository/interface/i_home_repository.dart';
import 'package:sadak/core/service/map/implementation/location_service_impl.dart';
import 'package:sadak/core/service/map/interface/i_geocoding_service.dart';
import 'package:sadak/core/service/map/interface/i_location_service.dart';
import '../../core/auth/service/i_auth_service.dart';
import '../../core/auth/service/auth_service.dart';
import '../../core/auth/repository/auth_repository.dart';
import '../../core/auth/view_model/auth_view_model.dart';



/// Services
final authServiceProvider =
    Provider<IAuthService>((_) => AuthService());

/// Repositories
final authRepoProvider =
    Provider<AuthRepository>(
        (ref) => AuthRepository(ref.read(authServiceProvider)));

/// ViewModels
final loginVMProvider =
    NotifierProvider<LoginViewModel, LoginState>(
        LoginViewModel.new);

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final communityRouteRepositoryProvider =
    Provider<ICommunityRouteRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  return FirebaseCommunityRouteRepository(firestore);
});

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
});

final geocodingServiceProvider =
    Provider<IGeocodingService>((ref) {
  final dio = ref.watch(dioProvider);

  return GeocodingServiceImpl(
    dio: dio,
    apiKey: 'YOUR_API_KEY',
  );
});



final locationServiceProvider =
    Provider<ILocationService>((ref) {
  return LocationServiceImpl();
});


final homeRepositoryProvider =
    Provider<IHomeRepository>((ref) {
  return HomeRepositoryImpl(
    locationService: ref.watch(locationServiceProvider),
    geocodingService: ref.watch(geocodingServiceProvider),
  );
});







