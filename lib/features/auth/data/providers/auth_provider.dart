import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

class AuthDataProvider {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Dio _dio;

  AuthDataProvider(this._dio);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Future<String?> getToken() async {
    return await _firebaseAuth.currentUser?.getIdToken();
  }

  Future<Response> syncUser() async {
    // El Interceptor ya inyectó el "Bearer <token>" automáticamente
    return await _dio.get('/users/me');
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _dio.patch('/users/me', data: data);
  }
}
