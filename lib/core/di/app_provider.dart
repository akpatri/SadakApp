import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sadak/view_model/home_view_model.dart';

import '../../service/i_auth_service.dart';
import '../../service/auth_service.dart';
import '../../data/repository/auth_repository.dart';
import '../../view_model/login_view_model.dart';
import '../../service/i_location_service.dart';
import '../../service/location_service.dart';

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

//locationService
final locationServiceProvider =
    Provider<ILocationService>(
  (ref) => LocationService(),
);

final homeVMProvider =AsyncNotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
