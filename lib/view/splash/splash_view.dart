import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../view_model/splash_view_model.dart';

class SplashView extends ConsumerWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ref.listen<SplashState>(splashVMProvider, (previous, next) {
      if (next.ready) {
        context.go('/login');
      }
    });

    return Scaffold(
      body: Center(
        child: Lottie.asset(
          "assets/animations/cycleroute.json",
          repeat: true,
        ),
      ),
    );
  }
}
