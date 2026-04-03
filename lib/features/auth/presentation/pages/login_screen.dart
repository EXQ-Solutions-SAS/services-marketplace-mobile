import 'package:flutter/material.dart';
import 'package:services_marketplace_mobile/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/bloc/auth_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Definimos los controladores aquí
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          // Efecto de resplandor
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
            child: Center(
              // Center para que no flote arriba en pantallas grandes
              child: SingleChildScrollView(
                // Para que no de error de pixeles si sale el teclado
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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

                    // Inputs con sus controladores
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Contraseña",
                        prefixIcon: Icon(Icons.lock_person_outlined),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 2. BlocConsumer para manejar estados de la UI
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.redAccent,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const CircularProgressIndicator();
                        }

                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity, // Botón ancho completo
                              child: ElevatedButton(
                                onPressed: () {
                                  final email = emailController.text.trim();
                                  final password = passwordController.text
                                      .trim();

                                  if (email.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Por favor, llena todos los campos",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  context.read<AuthBloc>().add(
                                    AuthLoginRequested(
                                      email,
                                      password,
                                    ),
                                  );
                                },
                                child: const Text("Ingresar"),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              child: const Text(
                                "¿No tienes cuenta? Regístrate aquí",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
