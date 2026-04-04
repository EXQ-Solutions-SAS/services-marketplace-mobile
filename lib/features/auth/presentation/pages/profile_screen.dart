import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/core/theme/app_theme.dart';
import 'package:services_marketplace_mobile/features/auth/data/models/user_model.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:services_marketplace_mobile/features/navigation/presentation/navigation_bloc.dart';
import 'package:services_marketplace_mobile/features/navigation/presentation/navigation_event.dart';
import 'package:services_marketplace_mobile/features/navigation/presentation/navigation_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    // Inicializamos vacíos para evitar errores de null
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();

    // Cargamos los datos después del primer frame de forma segura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AuthBloc>().state;
      if (state is Authenticated) {
        _nameController.text = state.user.name ?? "";
        _phoneController.text = state.user.phone ?? "";
        _bioController.text = state.user.bio ?? "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is! Authenticated) return const SizedBox();
        final user = state.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Mi Perfil"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: () =>
                    context.read<AuthBloc>().add(AuthLogoutRequested()),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar y Rol
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.2),
                  child: Text(
                    user.email[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      color: AppTheme.accentPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Chip(
                  label: Text(user.role.name),
                  backgroundColor: user.role == UserRole.PROVIDER
                      ? AppTheme.primaryOrange
                      : Colors.blueGrey,
                ),
                const SizedBox(height: 10),
                // ... dentro del Column
                BlocBuilder<NavigationBloc, NavigationState>(
                  builder: (context, navState) {
                    // Usamos el 'state' que viene del BlocConsumer de afuera
                    if (state.user.role == UserRole.PROVIDER) {
                      return SwitchListTile(
                        title: const Text("Modo Proveedor"),
                        subtitle: Text(
                          navState.isProviderMode
                              ? "Gestionando mi negocio"
                              : "Buscando servicios",
                        ),
                        secondary: Icon(
                          navState.isProviderMode
                              ? Icons.store
                              : Icons.person_outline,
                        ),
                        value: navState.isProviderMode,
                        activeColor: AppTheme
                            .primaryOrange, // activeThumbColor a veces da guerra, mejor activeColor
                        onChanged: (value) {
                          context.read<NavigationBloc>().add(ToggleUserMode());
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 30),

                // Formulario
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Nombre Completo",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "Teléfono",
                    prefixIcon: Icon(Icons.phone_android_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Biografía profesional",
                    prefixIcon: Icon(Icons.history_edu),
                  ),
                ),
                const SizedBox(height: 30),

                // Botón Guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        AuthUpdateProfileRequested(
                          name: _nameController.text,
                          phone: _phoneController.text,
                          bio: _bioController.text,
                        ),
                      );
                    },
                    child: const Text("Guardar Cambios"),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón dinámico: Solo si es CLIENT mostramos "Volverse Provider"
                if (user.role == UserRole.CLIENT)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryOrange),
                      ),
                      onPressed: () {
                        context.push('/create-service');
                      },
                      child: const Text(
                        "Ofrecer mis Servicios",
                        style: TextStyle(color: AppTheme.primaryOrange),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
