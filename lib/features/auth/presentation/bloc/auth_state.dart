import 'package:services_marketplace_mobile/features/auth/data/models/user_model.dart';

import 'auth_bloc.dart';

class Authenticated extends AuthState {
  final UserModel user; // Ya no es el User de Firebase, sino nuestro UserModel con Rol
  Authenticated(this.user);
  
  @override
  List<Object?> get props => [user];
}