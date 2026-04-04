import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:services_marketplace_mobile/features/services/data/models/service_model.dart';

class BookingSetupSheet extends StatefulWidget {
  final ServiceModel service;
  final Function(DateTime date, int hours) onConfirm;

  const BookingSetupSheet({
    super.key, 
    required this.service, 
    required this.onConfirm
  });

  @override
  State<BookingSetupSheet> createState() => _BookingSetupSheetState();
}

class _BookingSetupSheetState extends State<BookingSetupSheet> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int hours = 1;

  double get totalPrice => widget.service.pricePerHour * hours;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reservar ${widget.service.title}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Selector de Fecha y Hora
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text("Fecha"),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  leading: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text("Hora"),
                  subtitle: Text(selectedTime.format(context)),
                  leading: const Icon(Icons.access_time),
                  onTap: _selectTime,
                ),
              ),
            ],
          ),
          
          const Divider(),
          
          // Selector de Horas
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Duración del servicio", style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: hours > 1 ? () => setState(() => hours--) : null,
                    ),
                    Text("$hours hr", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => hours++),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Resumen de Precio
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total a pagar:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "\$${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final finalDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                widget.onConfirm(finalDateTime, hours);
                Navigator.pop(context);
              },
              child: const Text("Confirmar Reserva"),
            ),
          ),
        ],
      ),
    );
  }
}