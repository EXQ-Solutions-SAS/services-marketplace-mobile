import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:services_marketplace_mobile/core/api/api_client.dart';
import 'package:services_marketplace_mobile/core/router/app_router.dart';
import 'package:services_marketplace_mobile/core/theme/app_theme.dart';
import 'package:services_marketplace_mobile/features/auth/data/providers/auth_provider.dart';
import 'package:services_marketplace_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/data/providers/booking_provider.dart';
import 'package:services_marketplace_mobile/features/bookings/data/repositories/booking_repository.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:services_marketplace_mobile/features/services/data/providers/service_provider.dart';
import 'package:services_marketplace_mobile/features/services/data/repositories/service_repository.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_bloc.dart';
import 'package:services_marketplace_mobile/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final apiClient = ApiClient();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthDataProvider(apiClient.dio),
        ),
        RepositoryProvider(
          create: (context) => AuthRepository(context.read<AuthDataProvider>()),
        ),
        RepositoryProvider(
          create: (context) => ServiceDataProvider(apiClient.dio),
        ),
        RepositoryProvider(
          create: (context) => ServiceRepository(context.read<ServiceDataProvider>()),
        ),
        RepositoryProvider(
          create: (context) => BookingDataProvider(apiClient.dio),
        ),
        RepositoryProvider(
          create: (context) => BookingRepository(context.read<BookingDataProvider>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => ServiceBloc(context.read<ServiceRepository>()),
          ),
          BlocProvider(
            create: (context) => BookingBloc(context.read<BookingRepository>()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false, // Quita la etiqueta roja de "Debug"
      theme: AppTheme.darkTheme,
      routerConfig: createRouter(context.read<AuthBloc>()),
      title: 'Services Marketplace',
    );
  }
}
