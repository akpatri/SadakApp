import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  Stream<User?> authState();

  Future<void> sendOtp({
    required String phone,
    required Function(String id) onCodeSent,
    required Function(String error) onError,
  });

  Future<void> verifyOtp(String id, String code);

  Future<void> logout();
}
