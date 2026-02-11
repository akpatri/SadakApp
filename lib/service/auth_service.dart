import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'i_auth_service.dart';

class AuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<User?> authState() => _auth.authStateChanges();

  @override
  Future<void> sendOtp({
    required String phone,
    required Function(String id) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (cred) async {
        await _auth.signInWithCredential(cred);
        await _createUser();
      },
      verificationFailed: (e) =>
          onError(e.message ?? "Verification failed"),
      codeSent: (id, _) => onCodeSent(id),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Future<void> verifyOtp(String id, String code) async {
    final cred = PhoneAuthProvider.credential(
      verificationId: id,
      smsCode: code,
    );

    await _auth.signInWithCredential(cred);
    await _createUser();
  }

  Future<void> _createUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = _db.collection("users").doc(user.uid);

    if (!(await doc.get()).exists) {
      await doc.set({
        "uid": user.uid,
        "phone": user.phoneNumber,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> logout() => _auth.signOut();
}
