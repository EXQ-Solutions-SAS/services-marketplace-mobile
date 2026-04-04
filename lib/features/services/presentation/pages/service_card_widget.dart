import 'package:flutter/material.dart';
import 'package:services_marketplace_mobile/core/theme/app_theme.dart';
import 'package:services_marketplace_mobile/features/services/data/models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  // NUEVO: Parámetros opcionales para gestión
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.service,
    // Por defecto no mostramos acciones (para el Marketplace)
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos el diseño que ya teníamos
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          // Cambiamos Padding por Column para controlar el layout
          children: [
            // Row superior: Categoría y Precio (y acciones si es necesario)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Categoría
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service.category.name,
                      style: const TextStyle(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Área Derecha: Precio O Acciones
                  if (showActions)
                    // Si estamos en gestión, mostramos acciones en lugar del precio
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: onEdit,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: onDelete,
                        ),
                      ],
                    )
                  else
                    // Si estamos en Marketplace, mostramos el precio
                    Text(
                      "\$${service.pricePerHour.toStringAsFixed(0)}/hr",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                ],
              ),
            ),

            // Row de Precio (solo si estamos en gestión, lo movemos aquí abajo)
            if (showActions)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "\$${service.pricePerHour.toStringAsFixed(0)}/hr",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),

            // Resto del Card (Título, Descripción, Divisor, Proveedor)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.accentPurple,
                        radius: 14,
                        child: Text(
                          service.providerName[0],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Ofrecido por: ${service.providerName}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
