import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

final splashVMProvider =
    NotifierProvider<SplashViewModel, SplashState>(SplashViewModel.new);

class SplashViewModel extends Notifier<SplashState> {
  @override
  SplashState build() {
    _initialize();
    return const SplashState.loading();
  }

  Future<void> _initialize() async {
    // let animation start first frame
    await Future.delayed(const Duration(milliseconds: 300));

    // run heavy init async (non blocking)
    await Firebase.initializeApp();

    // simulate other services init if needed
    await Future.delayed(const Duration(seconds: 1));

    state = const SplashState.ready();
  }
}

class SplashState {
  final bool ready;

  const SplashState._(this.ready);

  const SplashState.loading() : ready = false;
  const SplashState.ready() : ready = true;
}
