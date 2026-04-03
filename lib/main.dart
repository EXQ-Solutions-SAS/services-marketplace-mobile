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
        // 1. Inyectamos el cliente Dio a través del Data Provider
        RepositoryProvider(
          create: (context) => AuthDataProvider(apiClient.dio),
        ),
        // 2. Inyectamos el Provider al Repository
        RepositoryProvider(
          create: (context) => AuthRepository(context.read<AuthDataProvider>()),
        ),

        RepositoryProvider(
          create: (context) => ServiceDataProvider(apiClient.dio),
        ),
        RepositoryProvider(
          create: (context) => ServiceRepository(context.read<ServiceDataProvider>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // 3. El BLoC queda disponible para TODA la app
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => ServiceBloc(context.read<ServiceRepository>()),
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
