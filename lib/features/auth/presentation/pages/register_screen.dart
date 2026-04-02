import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Crea tu cuenta",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Únete al marketplace de servicios más pro.",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Nombre completo",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                hintText: "Teléfono",
                prefixIcon: Icon(Icons.phone_android),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Contraseña",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),

            const SizedBox(height: 40),

            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Si ya está autenticado, no mostramos el botón (opcional)
                if (state is Authenticated) {
                  return const Center(
                    child: Icon(Icons.check_circle, color: Colors.green),
                  );
                }

                return Column(
                  children: [
                    // Botón principal de registro
                    SizedBox(
                      width: double.infinity, // Para que ocupe todo el ancho
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            AuthRegisterRequested(
                              email: emailController.text,
                              password: passwordController.text,
                              name: nameController.text,
                              phone: phoneController.text,
                            ),
                          );
                        },
                        child: const Text("Registrarme"),
                      ),
                    ),

                    const SizedBox(height: 16), // Espacio entre botones
                    // Botón plano para volver al Login
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        "¿Ya tienes cuenta? Inicia sesión",
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
    );
  }
}
