enum UserRole { customer, provider, admin }

class UserModel {
  final String id;
  final String email;
  final UserRole role;

  UserModel({required this.id, required this.email, required this.role});

  // Para convertir lo que viene de NestJS a objeto Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
    );
  }
}