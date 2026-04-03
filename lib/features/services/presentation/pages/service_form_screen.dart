import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/services/data/models/service_model.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_bloc.dart';
import 'package:services_marketplace_mobile/core/theme/app_theme.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_event.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_state.dart';
import 'package:go_router/go_router.dart';
class ServiceFormScreen extends StatefulWidget {
  final ServiceModel? service; // Si viene, editamos. Si no, creamos.

  const ServiceFormScreen({super.key, this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Usamos late para inicializarlos con el valor del servicio si existe
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String? _selectedCategoryId;

  bool get isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    
    // Inicialización dinámica
    _titleController = TextEditingController(text: widget.service?.title ?? '');
    _descriptionController = TextEditingController(text: widget.service?.description ?? '');
    _priceController = TextEditingController(
      text: widget.service?.pricePerHour.toString() ?? '',
    );
    // Extraemos el ID de la categoría del objeto category
    _selectedCategoryId = widget.service?.category.id;

    // Cargamos las categorías al entrar
    context.read<ServiceBloc>().add(FetchCategoriesRequested());
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      if (isEditing) {
        // EVENTO EDITAR
        context.read<ServiceBloc>().add(
          UpdateServiceRequested(
            widget.service!.id,
            {
              "title": _titleController.text,
              "description": _descriptionController.text,
              "pricePerHour": double.parse(_priceController.text),
              "categoryId": _selectedCategoryId,
            },
          ),
        );
      } else {
        // EVENTO CREAR
        context.read<ServiceBloc>().add(
          CreateServiceRequested(
            title: _titleController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            categoryId: _selectedCategoryId!,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar servicio" : "Ofrecer nuevo servicio"),
      ),
      body: BlocListener<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successBlue,
              ),
            );
            context.pop(); 
          }
          if (state is ServiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Dropdown de Categorías
                BlocBuilder<ServiceBloc, ServiceState>(
                  buildWhen: (previous, current) =>
                      current is CategoriesLoaded || current is ServiceLoading,
                  builder: (context, state) {
                    if (state is CategoriesLoaded) {
                      final categories = state.categories;
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: "Categoría",
                        ),
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() {
                          _selectedCategoryId = value;
                          final selectedCat = categories.firstWhere(
                            (c) => c.id == value,
                          );
                          // Solo auto-rellenar precio si estamos creando (para no sobreescribir el actual al editar)
                          if (!isEditing && selectedCat.basePrice != null) {
                            _priceController.text = selectedCat.basePrice.toString();
                          }
                        }),
                        validator: (value) =>
                            value == null ? "Selecciona una categoría" : null,
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Título del servicio (ej. Plomería)",
                  ),
                  validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Descripción detallada",
                  ),
                  validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Precio por hora (\$)",
                    prefixText: "\$ ",
                  ),
                  validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(isEditing ? "Guardar Cambios" : "Publicar Servicio"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}