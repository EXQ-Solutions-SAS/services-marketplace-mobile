import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:services_marketplace_mobile/features/auth/data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

// Eventos
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested(this.email, this.password);
}

class AuthLogoutRequested extends AuthEvent {}

class AuthRegisterRequested extends AuthEvent {
  final String email, password, name, phone;
  AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
  });
}

class AuthUpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? phone;
  final String? bio;

  AuthUpdateProfileRequested({this.name, this.phone, this.bio});
}

// Estados
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];

  UserModel? get user => this is Authenticated ? (this as Authenticated).user : null;
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.login(event.email, event.password);
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await repository.logout();
      emit(Unauthenticated());
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.register(
          email: event.email,
          password: event.password,
          name: event.name,
          phone: event.phone,
        );
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthUpdateProfileRequested>((event, emit) async {
      // Guardamos el usuario actual para no perderlo en caso de error
      final currentState = state;
      if (currentState is Authenticated) {
        emit(
          AuthLoading(),
        ); // O podrías crear un estado AuthUpdating si no quieres tapar toda la pantalla
        try {
          final updatedUser = await repository.updateProfile(
            name: event.name,
            phone: event.phone,
            bio: event.bio,
          );

          // Emitimos el nuevo estado con el usuario fresco de la DB
          emit(Authenticated(updatedUser));
        } catch (e) {
          emit(AuthError(e.toString()));
          // Opcional: Re-emitir Authenticated con el usuario previo después del error
          emit(Authenticated(currentState.user));
        }
      }
    });
  }
}
