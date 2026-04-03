import 'package:flutter/material.dart';
import 'package:services_marketplace_mobile/core/theme/app_theme.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/pages/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text("Explorar Servicios", style: TextStyle(color: Colors.white))),
    const Center(child: Text("Mis Bookings", style: TextStyle(color: Colors.white))),
    const ProfileScreen(), // Nuestra nueva pantalla
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppTheme.backgroundDark,
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}