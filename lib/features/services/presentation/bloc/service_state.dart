import 'package:equatable/equatable.dart';
import 'package:services_marketplace_mobile/features/services/data/models/category_model.dart';
import 'package:services_marketplace_mobile/features/services/data/models/service_model.dart';

abstract class ServiceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}
class ServiceLoading extends ServiceState {}

// Estado cuando ya tenemos la lista de servicios
class ServicesLoaded extends ServiceState {
  final List<ServiceModel> services;
  ServicesLoaded(this.services);
  @override
  List<Object?> get props => [services];
}

// Estado cuando cargamos las categorías para el Dropdown
class CategoriesLoaded extends ServiceState {
  final List<CategoryModel> categories;
  CategoriesLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

class ServiceSuccess extends ServiceState {
  final String message;
  ServiceSuccess(this.message);
}

class ServiceError extends ServiceState {
  final String message;
  ServiceError(this.message);
}