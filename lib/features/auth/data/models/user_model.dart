enum UserRole {
  CLIENT,
  PROVIDER,
  ADMIN,
} // Cámbialos a mayúsculas como en Prisma

class UserModel {
  final String id;
  final String email;
  final UserRole role;
  final String? name;
  final String? phone;
  final String? bio;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.phone,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      bio: json['bio'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.CLIENT,
      ),
    );
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? bio,
    UserRole? role,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      role: role ?? this.role,
    );
  }
}
