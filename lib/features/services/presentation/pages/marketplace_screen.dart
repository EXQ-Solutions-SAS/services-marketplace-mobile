import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/bloc/auth_bloc.dart'
    show AuthBloc, Authenticated;
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_bloc.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_event.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_state.dart';
import 'package:services_marketplace_mobile/features/services/presentation/pages/service_card_widget.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    // USAR FUTURE.MICROTASK ayuda a que el contexto esté listo sin bloquear el frame
    Future.microtask(() {
      final authState = context.read<AuthBloc>().state;
      String? myId = authState is Authenticated ? authState.user.id : null;

      context.read<ServiceBloc>().add(
        StreamServicesStarted(excludeUserId: myId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Marketplace")),
      body: BlocBuilder<ServiceBloc, ServiceState>(
        buildWhen: (previous, current) =>
            current is MarketplaceLoaded ||
            current is ServiceLoading ||
            current is ServiceError,
        builder: (context, state) {
          if (state is ServiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ServiceError) {
            return Center(
              child: Text(
                "Error: ${state.message}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is MarketplaceLoaded) {
            if (state.services.isEmpty) {
              return const Center(
                child: Text("No hay servicios disponibles aún."),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.services.length,
              itemBuilder: (context, index) {
                final service = state.services[index];
                return ServiceCard(service: service);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
