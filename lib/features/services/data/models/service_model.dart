import 'package:services_marketplace_mobile/features/services/data/models/category_model.dart';

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final double pricePerHour;
  final DateTime createdAt;
  
  final CategoryModel category;
  final String providerName; 

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pricePerHour,
    required this.createdAt,
    required this.category,
    required this.providerName,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // 1. Extraemos el nombre del usuario navegando el JSON: provider -> user -> name
    final providerData = json['provider'];
    final userData = providerData != null ? providerData['user'] : null;
    final name = userData != null ? userData['name'] : 'Proveedor desconocido';

    return ServiceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Sin título',
      description: json['description'] ?? '',
      pricePerHour: (json['pricePerHour'] as num? ?? 0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      
      // 2. Mapeamos la categoría. Si el JSON de /services solo trae 'name', 
      // nuestro CategoryModel.fromJson lo manejará
      category: CategoryModel.fromJson(json['category'] ?? {}),
      
      providerName: name,
    );
  }
}