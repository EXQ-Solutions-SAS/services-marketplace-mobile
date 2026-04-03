import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/core/theme/app_theme.dart';
import 'package:services_marketplace_mobile/features/auth/data/models/user_model.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/pages/profile_screen.dart';
import 'package:services_marketplace_mobile/features/services/presentation/pages/marketplace_screen.dart';
import 'package:services_marketplace_mobile/features/services/presentation/pages/my_services_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // 1. Verificamos si es Provider
        final bool isProvider =
            authState is Authenticated &&
            authState.user.role == UserRole.PROVIDER;

        // 2. Definimos las pantallas dinámicamente
        final List<Widget> screens = [
          const MarketplaceScreen(),
          if (isProvider) const MyServicesScreen(), // <--- Pantalla nueva
          const ProfileScreen(),
        ];

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: screens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: AppTheme.backgroundDark,
            selectedItemColor: AppTheme.primaryOrange,
            unselectedItemColor: Colors.white54,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Explorar',
              ),
              if (isProvider)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.business_center),
                  label: 'Mis Servicios',
                ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}
