import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'i_auth_service.dart';

class FakeAuthService implements IAuthService {
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();

  @override
  Stream<User?> authState() => _controller.stream;

  @override
  Future<void> sendOtp({
    required String phone,
    required Function(String id) onCodeSent,
    required Function(String error) onError,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    onCodeSent("fake-verification-id");
  }

  @override
  Future<void> verifyOtp(String id, String code) async {
    await Future.delayed(const Duration(seconds: 1));

    if (code != "123456") {
      throw Exception("Invalid OTP");
    }

    _controller.add(null); // Simulate logged in
  }

  @override
  Future<void> logout() async {
    _controller.add(null);
  }
}
