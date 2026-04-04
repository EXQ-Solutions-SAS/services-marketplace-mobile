import 'package:dio/dio.dart';

class BookingDataProvider {
  final Dio _dio;

  BookingDataProvider(this._dio);

  // POST /bookings
  Future<Response> createBooking({
    required String serviceId,
    required DateTime scheduledAt,
    required int hours,
  }) async {
    return await _dio.post('/bookings', data: {
      'serviceId': serviceId,
      'scheduledAt': scheduledAt.toIso8601String(),
      'hours': hours,
    });
  }

  // GET /bookings/my-bookings (Cliente)
  Future<Response> getMyBookings() async {
    return await _dio.get('/bookings/my-bookings');
  }

  // GET /bookings/provider-dashboard (Proveedor)
  Future<Response> getProviderDashboard() async {
    return await _dio.get('/bookings/provider-dashboard');
  }

  // PATCH /bookings/:id/status
  Future<Response> updateBookingStatus(String id, String status) async {
    return await _dio.patch('/bookings/$id/status', data: {
      'status': status, // 'ACCEPTED', 'CANCELLED', etc.
    });
  }
}