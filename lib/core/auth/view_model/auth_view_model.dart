import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../external/di/app_provider.dart';
import '../repository/auth_repository.dart';

class LoginViewModel extends Notifier<LoginState> {
  late final AuthRepository repo;

  @override
  LoginState build() {
    repo = ref.read(authRepoProvider);
    return LoginState.initial();
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true);

    await repo.sendOtp(
      phone: phone,
      onCodeSent: (id) {
        state = state.copyWith(
          isLoading: false,
          verificationId: id,
          codeSent: true,
        );
      },
      onError: (err) {
        state = state.copyWith(
          isLoading: false,
          error: err,
        );
      },
    );
  }

  Future<void> verifyOtp(String code) async {
    if (state.verificationId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      await repo.verifyOtp(state.verificationId!, code);
      state = state.copyWith(
        isLoading: false,
        loggedIn: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: "Invalid OTP",
      );
    }
  }
}

class LoginState {
  final bool isLoading;
  final bool loggedIn;
  final bool codeSent;
  final String? verificationId;
  final String? error;

  const LoginState({
    required this.isLoading,
    required this.loggedIn,
    required this.codeSent,
    this.verificationId,
    this.error,
  });

  factory LoginState.initial() =>
      const LoginState(
        isLoading: false,
        loggedIn: false,
        codeSent: false,
      );

  LoginState copyWith({
    bool? isLoading,
    bool? loggedIn,
    bool? codeSent,
    String? verificationId,
    String? error,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      loggedIn: loggedIn ?? this.loggedIn,
      codeSent: codeSent ?? this.codeSent,
      verificationId: verificationId ?? this.verificationId,
      error: error,
    );
  }
}
