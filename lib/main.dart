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
import 'package:services_marketplace_mobile/features/bookings/data/providers/payment_provider.dart';
import 'package:services_marketplace_mobile/features/bookings/data/repositories/booking_repository.dart';
import 'package:services_marketplace_mobile/features/bookings/data/repositories/payment_repository.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/payment_bloc.dart';
import 'package:services_marketplace_mobile/features/navigation/presentation/navigation_bloc.dart';
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
          create: (context) =>
              ServiceRepository(context.read<ServiceDataProvider>()),
        ),
        RepositoryProvider(
          create: (context) => BookingDataProvider(apiClient.dio),
        ),
        RepositoryProvider(
          create: (context) =>
              BookingRepository(context.read<BookingDataProvider>()),
        ),
        RepositoryProvider(
          create: (context) => PaymentDataProvider(apiClient.dio),
        ),
        RepositoryProvider(
          create: (context) =>
              PaymentRepository(context.read<PaymentDataProvider>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => ServiceBloc(
              context.read<ServiceRepository>(),
              context.read<AuthBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) => BookingBloc(
              context.read<BookingRepository>(),
              context.read<AuthBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) => NavigationBloc(), // No necesita parámetros
          ),
          BlocProvider(
            create: (context) => PaymentBloc(context.read<PaymentRepository>()),
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
