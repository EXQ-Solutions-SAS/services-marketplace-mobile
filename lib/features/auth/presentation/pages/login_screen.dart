import 'package:flutter/material.dart';
import 'package:services_marketplace_mobile/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart'; // <--- IMPORTANTE
// ... imports

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // Usamos Stack para meter un efecto de luz de fondo
        children: [
          // Efecto de resplandor (Glow) en la esquina superior
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentPurple.withValues(alpha: 0.15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  "Marketplace",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.normal,
                    color: AppTheme.primaryOrange,
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  "Premium Services",
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                ),
                const SizedBox(height: 50),

                // Los TextFields usarán automáticamente el tema que definimos
                const TextField(
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Contraseña",
                    prefixIcon: Icon(Icons.lock_person_outlined),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () {
                    // Acción de login
                  },
                  child: const Text("Ingresar"),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => context.push(
                    '/register',
                  ), // .push para que pueda volver atrás
                  child: const Text(
                    "¿No tienes cuenta? Regístrate aquí",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
