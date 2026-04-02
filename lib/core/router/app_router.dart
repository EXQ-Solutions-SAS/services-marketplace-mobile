import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:services_marketplace_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/pages/login_screen.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: BlocListenable(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final bool isLoggingIn = state.matchedLocation == '/login';

      if (authState is! Authenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) return '/';

      // Aquí podrías añadir la lógica de roles más adelante
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(), 
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home - Autenticado')),
        ),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const Placeholder(),
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