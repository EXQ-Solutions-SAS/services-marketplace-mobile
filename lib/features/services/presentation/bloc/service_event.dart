import 'package:equatable/equatable.dart';

abstract class ServiceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StreamServicesStarted extends ServiceEvent {
  final String? excludeUserId; // <--- Añadimos esto

  StreamServicesStarted({this.excludeUserId});

  @override
  List<Object?> get props => [excludeUserId];
} 

class StreamMyServicesStarted extends ServiceEvent {} // Nuevo evento

class ResetServiceState extends ServiceEvent {}

// Cargar categorías para el formulario de creación
class FetchCategoriesRequested extends ServiceEvent {}

// Crear un nuevo servicio
class CreateServiceRequested extends ServiceEvent {
  final String title;
  final String description;
  final double price;
  final String categoryId;

  CreateServiceRequested({
    required this.title, 
    required this.description, 
    required this.price, 
    required this.categoryId
  });

  @override
  List<Object?> get props => [title, description, price, categoryId];
}