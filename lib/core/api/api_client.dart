import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importar dotenv
import 'dart:io';

class ApiClient {
  late Dio dio;

  ApiClient() {
    // Sacamos la URL del .env dependiendo de la plataforma
    final baseUrl = Platform.isAndroid 
        ? dotenv.env['API_URL_ANDROID'] 
        : dotenv.env['API_URL_IOS'];

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? 'http://localhost:3000',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }
}