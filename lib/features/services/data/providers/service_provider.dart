import 'package:dio/dio.dart';

class ServiceDataProvider {
  final Dio _dio;

  ServiceDataProvider(this._dio);

  // GET /categories
  Future<Response> getCategories() async {
    return await _dio.get('/categories');
  }

  // GET /services
  Future<Response> getServices() async {
    return await _dio.get('/services');
  }

  // POST /services
  Future<Response> createService(Map<String, dynamic> data) async {
    return await _dio.post('/services', data: data);
  }

  // PATCH /services/:id
  Future<Response> updateService(String id, Map<String, dynamic> data) async {
    return await _dio.patch('/services/$id', data: data);
  }
}