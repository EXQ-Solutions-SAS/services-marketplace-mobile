import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:services_marketplace_mobile/features/services/data/models/service_model.dart';
import 'package:services_marketplace_mobile/features/services/data/repositories/service_repository.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_event.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository repository;
  final AuthBloc _authBloc;
  StreamSubscription? _authSubscription;
  StreamSubscription? _marketplaceSubscription;
  StreamSubscription? _myServicesSubscription;

  ServiceBloc(this.repository, this._authBloc) : super(ServiceInitial()) {
    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState is Unauthenticated) {
        // SI CIERRA SESIÓN, MATAMOS EL STREAM DE DATOS
        add(StopServiceStream());
      }
    });

    on<StopServiceStream>((event, emit) {
      _marketplaceSubscription?.cancel();
      _myServicesSubscription?.cancel();
      _marketplaceSubscription = null;
      _myServicesSubscription = null;
      emit(ServiceInitial()); // Limpiamos el estado
    });
    // 1. Manejar carga de servicios
    // Marketplace
    on<StreamServicesStarted>((event, emit) async {
      await _myServicesSubscription?.cancel();

      if (state is! MarketplaceLoaded) {
        emit(ServiceLoading());
      }

      // IMPORTANTE: Asigna la suscripción para que el próximo evento pueda cancelarla
      _marketplaceSubscription = repository
          .getServicesStream(excludeUserId: event.excludeUserId)
          .listen((_) {});

      await emit.forEach<List<ServiceModel>>(
        repository.getServicesStream(excludeUserId: event.excludeUserId),
        onData: (services) => MarketplaceLoaded(services),
        onError: (error, _) => ServiceError(error.toString()),
      );
    });

    // Mis Servicios
    on<StreamMyServicesStarted>((event, emit) async {
      await _marketplaceSubscription?.cancel();

      if (state is! MyServicesLoaded) {
        emit(ServiceLoading());
      }

      _myServicesSubscription = repository.getMyServicesStream().listen((_) {});

      await emit.forEach<List<ServiceModel>>(
        repository.getMyServicesStream(),
        onData: (services) => MyServicesLoaded(services),
        onError: (error, _) => ServiceError(error.toString()),
      );
    });
    // 2. Manejar carga de categorías
    on<FetchCategoriesRequested>((event, emit) async {
      emit(ServiceLoading());
      try {
        final categories = await repository.fetchCategories();
        emit(CategoriesLoaded(categories));
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });

    // 3. Crear Servicio
    on<CreateServiceRequested>((event, emit) async {
      emit(ServiceLoading());
      try {
        await repository.createService(
          title: event.title,
          description: event.description,
          price: event.price,
          categoryId: event.categoryId,
        );
        emit(ServiceSuccess("¡Servicio creado con éxito!"));
        // Tip: Podrías re-lanzar FetchServicesRequested aquí si quieres actualizar la lista
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });

    on<ResetServiceState>((event, emit) async {
      // Cancelamos ambos para estar seguros
      await _marketplaceSubscription?.cancel();
      await _myServicesSubscription?.cancel();
      _marketplaceSubscription = null;
      _myServicesSubscription = null;

      emit(ServiceInitial()); // Volvemos al estado base
    });

    on<DeleteServiceRequested>((event, emit) async {
      try {
        await repository.deleteService(event.id);

        // 1. Primero reiniciamos el stream para que el usuario vea
        // que el card desaparece inmediatamente
        add(StreamMyServicesStarted());

        // 2. Notificamos el éxito (el listener del Consumer lo atrapará)
        emit(const ServiceSuccess("Servicio eliminado correctamente"));
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });

    on<UpdateServiceRequested>((event, emit) async {
      emit(ServiceLoading());
      try {
        await repository.updateService(event.id, event.data);
        emit(const ServiceSuccess("Servicio actualizado"));
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });

    @override
    Future<void> close() {
      _authSubscription?.cancel();
      _marketplaceSubscription?.cancel();
      _myServicesSubscription?.cancel();
      return super.close();
    }
  }
}
