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

  // En service_repository.dart

  Stream<List<ServiceModel>> getServicesStream({String? excludeUserId}) async* {
    // TRUCO: El bucle debe ejecutar la lógica y LUEGO esperar
    while (true) {
      try {
        final response = await provider.getServices(
          excludeUserId: excludeUserId,
        );
        final List data = response.data;
        yield data.map((json) => ServiceModel.fromJson(json)).toList();
      } catch (e) {
        yield* Stream.error("Error en Marketplace");
      }

      // La espera va AL FINAL del ciclo
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Stream<List<ServiceModel>> getMyServicesStream() async* {
    while (true) {
      try {
        final response = await provider.getMyServices();
        final List data = response.data;
        yield data.map((json) => ServiceModel.fromJson(json)).toList();
      } catch (e) {
        yield* Stream.error("Error en Mis Servicios");
      }

      await Future.delayed(const Duration(seconds: 5));
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
