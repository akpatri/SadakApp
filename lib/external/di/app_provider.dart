import 'package:flutter_riverpod/flutter_riverpod.dart';
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




