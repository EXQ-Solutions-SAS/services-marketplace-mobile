import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

class AuthDataProvider {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Dio _dio;

  AuthDataProvider(this._dio);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getToken() async {
    return await _firebaseAuth.currentUser?.getIdToken();
  }

  Future<Response> syncUserWithBackend(String token) async {
    return await _dio.post('/auth/register', data: {
      'token': token,
    });
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}