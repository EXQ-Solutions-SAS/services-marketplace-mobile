enum UserRole { CLIENT, PROVIDER, ADMIN } // Cámbialos a mayúsculas como en Prisma

class UserModel {
  final String id;
  final String email;
  final UserRole role;
  final String? name;  // Aprovecha para agregar estos campos
  final String? phone; // que ya vimos que vienen en el JSON

  UserModel({
    required this.id, 
    required this.email, 
    required this.role,
    this.name,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      // Agregamos un orElse por seguridad para que no explote si llega algo raro
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.CLIENT, 
      ),
    );
  }
}