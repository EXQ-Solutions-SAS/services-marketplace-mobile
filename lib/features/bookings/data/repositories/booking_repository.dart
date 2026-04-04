import '../models/booking_model.dart';
import '../providers/booking_provider.dart';

class BookingRepository {
  final BookingDataProvider provider;

  BookingRepository(this.provider);

  Future<void> createBooking(String serviceId, DateTime date, int hours) async {
    await provider.createBooking(
      serviceId: serviceId,
      scheduledAt: date,
      hours: hours,
    );
  }

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

  Future<void> updateStatus(String id, BookingStatus status) async {
    await provider.updateBookingStatus(id, status.name);
  }
}