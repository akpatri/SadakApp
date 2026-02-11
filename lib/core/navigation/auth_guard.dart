import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

String? authGuard(GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null && state.fullPath != "/login") {
    return "/login";
  }

  if (user != null && state.fullPath == "/login") {
    return "/";
  }

  return null;
}
