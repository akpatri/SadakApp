import '../../service/i_auth_service.dart';

class AuthRepository {
  final IAuthService _service;

  AuthRepository(this._service);

  Stream authState() => _service.authState();

  Future<void> sendOtp({
    required String phone,
    required Function(String id) onCodeSent,
    required Function(String error) onError,
  }) =>
      _service.sendOtp(
        phone: phone,
        onCodeSent: onCodeSent,
        onError: onError,
      );

  Future<void> verifyOtp(String id, String code) =>
      _service.verifyOtp(id, code);

  Future<void> logout() => _service.logout();
}
