import 'package:services_marketplace_mobile/features/auth/data/models/user_model.dart';

import '../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AuthDataProvider provider;

  AuthRepository(this.provider);

  Future<UserModel?> login(String email, String password) async {
    final token = await provider.getToken();

    if (token != null) {
      // Sincronizamos (el back nos devuelve el usuario de Postgres)
      final response = await provider.syncUser();
      return UserModel.fromJson(response.data);
    }
    return null;
  }

  Stream<User?> get currentUser => provider.authStateChanges;

  Future<void> logout() async => await provider.signOut();

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final credential = await provider.signUp(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );

    final token = await credential.user?.getIdToken();

    if (token != null) {
      final response = await provider.syncUser();
      return UserModel.fromJson(response.data);
    }
    throw Exception("Error obteniendo Token");
  }
}
