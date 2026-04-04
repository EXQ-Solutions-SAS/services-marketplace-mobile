import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/core/theme/app_theme.dart';
import 'package:services_marketplace_mobile/features/auth/data/models/user_model.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/pages/profile_screen.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/pages/customer_bookings_screen.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/pages/provider_bookings_screen.dart';
import 'package:services_marketplace_mobile/features/navigation/presentation/navigation_bloc.dart';
import 'package:services_marketplace_mobile/features/navigation/presentation/navigation_event.dart';
import 'package:services_marketplace_mobile/features/navigation/presentation/navigation_state.dart';
import 'package:services_marketplace_mobile/features/services/presentation/pages/marketplace_screen.dart';
import 'package:services_marketplace_mobile/features/services/presentation/pages/my_services_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navState) {
        // Definimos qué vemos según el modo
        final List<Widget> screens = navState.isProviderMode 
          ? [const ProviderBookingsScreen(), const MyServicesScreen(), const ProfileScreen()]
          : [const MarketplaceScreen(), const CustomerBookingsScreen(), const ProfileScreen()];

        return Scaffold(
          body: IndexedStack(
            index: navState.selectedIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navState.selectedIndex,
            onTap: (index) => context.read<NavigationBloc>().add(ChangeTab(index)),
            selectedItemColor: AppTheme.primaryOrange,
            items: navState.isProviderMode 
                ? _providerItems() 
                : _customerItems(),
          ),
        );
      },
    );
  }

  List<BottomNavigationBarItem> _customerItems() => [
    const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
    const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Mis Pedidos'),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
  ];

  List<BottomNavigationBarItem> _providerItems() => [
    const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    const BottomNavigationBarItem(icon: Icon(Icons.business_center), label: 'Mis Servicios'),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
  ];
}