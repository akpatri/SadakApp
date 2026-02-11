import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/di/app_provider.dart';
import 'core/navigation/app_routes.dart';
import 'service/fake_auth_service.dart';
import 'service/fake_location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const useFakeAuth = true;
  const useFakeLocation = true;

  runApp(
    ProviderScope(
      overrides: [
        if (useFakeAuth)
          authServiceProvider
              .overrideWithValue(FakeAuthService()),
        if (useFakeLocation)
          locationServiceProvider
              .overrideWithValue(FakeLocationService()),
      ],
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
