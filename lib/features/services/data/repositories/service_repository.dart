// features/services/data/repositories/service_repository.dart
import '../models/category_model.dart';
import '../models/service_model.dart';
import '../providers/service_provider.dart';

class ServiceRepository {
  final ServiceDataProvider provider;

  ServiceRepository(this.provider);

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await provider.getCategories();
      return (response.data as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception("Error al cargar categorías");
    }
  }

  // En ServiceRepository
  Stream<List<ServiceModel>> getServicesStream() async* {
    while (true) {
      try {
        final response = await provider.getServices();
        final List servicesJson = response.data;
        yield servicesJson.map((e) => ServiceModel.fromJson(e)).toList();
      } catch (e) {
        yield* Stream.error("Error al sincronizar servicios");
      }
      // Esperamos 5-10 segundos antes de volver a pedir datos (polling)
      // Esto evita que la app se congele por peticiones infinitas
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  Future<ServiceModel> createService({
    required String title,
    required String description,
    required double price,
    required String categoryId,
  }) async {
    try {
      final response = await provider.createService({
        "title": title,
        "description": description,
        "pricePerHour": price,
        "categoryId": categoryId,
      });
      return ServiceModel.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al crear el servicio");
    }
  }
}
