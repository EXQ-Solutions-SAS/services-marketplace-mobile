import '../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AuthDataProvider provider;

  AuthRepository(this.provider);

   Future<User?> login(String email, String password) async {
    // 1. Login en Firebase
    final userCredential = await provider.signIn(email, password);
    final user = userCredential.user;

    if (user != null) {
      // 2. Obtener Token
      final token = await provider.getToken();
      
      // 3. Sincronizar con NestJS (para que exista en Postgres)
      if (token != null) {
        await provider.syncUserWithBackend(token);
      }
    }
    return user;
  }

  Stream<User?> get currentUser => provider.authStateChanges;

  Future<void> logout() async => await provider.signOut();
}