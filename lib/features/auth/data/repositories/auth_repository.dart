import 'package:services_marketplace_mobile/features/auth/data/models/user_model.dart';

import '../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AuthDataProvider provider;

  AuthRepository(this.provider);

  // En auth_repository.dart
  Future<UserModel?> login(String email, String password) async {
    try {
      // 1. Logueamos en Firebase usando el PROVIDER
      await provider.signIn(email, password);

      // 2. Si Firebase no lanzó error, pedimos los datos a nuestro NestJS
      final response = await provider
          .syncUser(); // Usamos syncUser o getUserData
      return UserModel.fromJson(response.data);
    } on FirebaseAuthException catch (e) {
      // Captura errores específicos de Firebase (contraseña mal, etc.)
      if (e.code == 'invalid-credential') {
        throw "El correo o la contraseña no son válidos.";
      }
      throw e.message ?? "Credenciales incorrectas";
    } catch (e) {
      throw "Error de conexión con el servidor";
    }
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

  // Dentro de AuthRepository
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? bio,
  }) async {
    try {
      // Creamos el mapa con los datos que no sean null
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (bio != null) updateData['bio'] = bio;

      final response = await provider.updateProfile(updateData);

      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al actualizar el perfil: $e");
    }
  }
}
