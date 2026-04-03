class CategoryModel {
  final String id;
  final String name;
  final String? description; 
  final double? basePrice;   
  final String? icon;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.basePrice,
    this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '', // Por si el GET /services no trae el ID de la categoría
      name: json['name'] ?? 'Sin categoría',
      description: json['description'], 
      basePrice: json['basePrice'] != null ? (json['basePrice'] as num).toDouble() : null,
      icon: json['icon'],
    );
  }
}
