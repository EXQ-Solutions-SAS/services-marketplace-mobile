import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:services_marketplace_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/pages/register_screen.dart';
import 'package:services_marketplace_mobile/features/home/presentation/pages/home_screen.dart';
import 'package:services_marketplace_mobile/features/services/data/models/service_model.dart';
import 'package:services_marketplace_mobile/features/services/presentation/pages/create_service_screen.dart';
import 'package:services_marketplace_mobile/features/services/presentation/pages/service_form_screen.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: BlocListenable(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final bool isLoggingIn = state.matchedLocation == '/login';
      final bool registering = state.matchedLocation == '/register';

      final bool isAuthenticated = authState is Authenticated;

      if (!isAuthenticated && !isLoggingIn && !registering) {
        return '/login';
      }

      // Si ya está autenticado e intenta ir a login o registro, al home.
      if (isAuthenticated && (isLoggingIn || registering)) {
        return '/';
      }

      // Aquí podrías añadir la lógica de roles más adelante
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const Placeholder()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/create-service',
        builder: (context, state) => const CreateServiceScreen(),
      ),
      GoRoute(
        path: '/service-form',
        builder: (context, state) {
          // Si pasamos un objeto ServiceModel en el 'extra', lo capturamos
          final service = state.extra as ServiceModel?;
          return ServiceFormScreen(service: service);
        },
      ),
    ],
  );
}

class BlocListenable<B extends Bloc<dynamic, dynamic>> extends ChangeNotifier {
  final B bloc;
  late final StreamSubscription _subscription;

  BlocListenable(this.bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
