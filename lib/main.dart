import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/di/app_provider.dart';
import 'service/fake_auth_service.dart';
import 'core/navigation/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Firebase only once
  await Firebase.initializeApp();

  const bool useFakeAuth = true;

  runApp(
    ProviderScope(
      overrides: useFakeAuth
          ? [
              authServiceProvider
                  .overrideWithValue(FakeAuthService()),
            ]
          : const [],
      child: const SadakApp(),
    ),
  );
}

class SadakApp extends ConsumerWidget {
  const SadakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Sadak',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
