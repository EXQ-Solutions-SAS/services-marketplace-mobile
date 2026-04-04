import '../models/booking_model.dart';
import '../providers/booking_provider.dart';

class BookingRepository {
  final BookingDataProvider provider;

  BookingRepository(this.provider);

  // --- STREAMS ---

  // Este stream emitirá la lista de reservas cada 10 segundos
  Stream<List<BookingModel>> getCustomerBookingsStream() async* {
    // Emitimos el primero de una vez
    yield await getCustomerBookings();
    
    // Luego preguntamos periódicamente
    yield* Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      return await getCustomerBookings();
    });
  }

  Stream<List<BookingModel>> getProviderBookingsStream() async* {
    yield await getProviderBookings();
    
    yield* Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      return await getProviderBookings();
    });
  }

  // --- FUTURES (Se quedan igual para acciones puntuales) ---

  Future<List<BookingModel>> getCustomerBookings() async {
    final response = await provider.getMyBookings();
    return (response.data as List)
        .map((json) => BookingModel.fromJson(json))
        .toList();
  }

  Future<List<BookingModel>> getProviderBookings() async {
    final response = await provider.getProviderDashboard();
    return (response.data as List)
        .map((json) => BookingModel.fromJson(json))
        .toList();
  }

  Future<void> createBooking(String serviceId, DateTime date, int hours) async {
    await provider.createBooking(
      serviceId: serviceId,
      scheduledAt: date,
      hours: hours,
    );
  }

  Future<void> updateStatus(String id, BookingStatus status) async {
    await provider.updateBookingStatus(id, status.name);
  }
}