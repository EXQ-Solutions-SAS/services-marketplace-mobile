import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_bloc.dart';
import 'package:services_marketplace_mobile/core/theme/app_theme.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_event.dart';
import 'package:services_marketplace_mobile/features/services/presentation/bloc/service_state.dart';
import 'package:go_router/go_router.dart';
class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Cargamos las categorías al entrar
    context.read<ServiceBloc>().add(FetchCategoriesRequested());
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ofrecer nuevo servicio")),
      body: BlocListener<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successBlue,
              ),
            );
            context.pop(); // Volvemos atrás al tener éxito
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
                          if (selectedCat.basePrice != null) {
                            _priceController.text = selectedCat.basePrice
                                .toString();
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
                  child: const Text("Publicar Servicio"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
