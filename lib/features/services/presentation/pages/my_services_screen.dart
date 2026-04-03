import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_bloc.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_event.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_state.dart';
import 'package:services_marketplace_mobile/features/services/presentation/pages/service_card_widget.dart';
import 'package:go_router/go_router.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  @override
  void initState() {
    super.initState();
    // Disparamos el stream de MIS servicios
    context.read<ServiceBloc>().add(StreamMyServicesStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Servicios"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/create-service');
              if (context.mounted) {
                context.read<ServiceBloc>().add(StreamMyServicesStarted());
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ServiceBloc, ServiceState>(
        buildWhen: (previous, current) =>
            current is MyServicesLoaded ||
            current is ServiceLoading ||
            current is ServiceError,
        builder: (context, state) {
          if (state is ServiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MyServicesLoaded) {
            final services = state.services;
            if (services.isEmpty) {
              return const Center(
                child: Text("Aún no has publicado servicios."),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Stack(
                  children: [
                    ServiceCard(service: service),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              /* Implementaremos editar luego */
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(service.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar servicio?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              // Aquí dispararías un nuevo evento: DeleteServiceRequested(id)
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
