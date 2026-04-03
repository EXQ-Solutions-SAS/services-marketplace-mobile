import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/services/data/models/service_model.dart';
import 'package:services_marketplace_mobile/features/services/data/repositories/service_repository.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_event.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository repository;

  ServiceBloc(this.repository) : super(ServiceInitial()) {
    // 1. Manejar carga de servicios
    on<StreamServicesStarted>((event, emit) async {
      // 1. Emitimos carga inicial solo la primera vez
      emit(ServiceLoading());

      // 2. Nos suscribimos al Stream del repository
      await emit.forEach<List<ServiceModel>>(
        repository.getServicesStream(),
        onData: (services) => ServicesLoaded(services),
        onError: (error, stackTrace) => ServiceError(error.toString()),
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
  }
}
