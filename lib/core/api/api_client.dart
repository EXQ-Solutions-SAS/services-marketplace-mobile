import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importante para el token
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
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Obtenemos el usuario actual de Firebase
          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            // 2. Obtenemos el ID Token (fresquito, Firebase lo refresca si expiró)
            final token = await user.getIdToken();

            // 3. Lo metemos en el Header Authorization
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options); // Continúa la petición
        },
        onError: (DioException e, handler) {
          // Opcional: Aquí podrías manejar errores 401 para desloguear al usuario
          return handler.next(e);
        },
      ),
    );

    // El LogInterceptor siempre de último para ver los headers ya inyectados
    dio.interceptors.add(
      LogInterceptor(
        request: false, // Desactiva el log de la URL de petición
        requestHeader: false,
        responseUrl: false,
        responseHeader: false,
        responseBody: false, // Esto es lo que más espacio ocupa
        error: true, // DEJA ESTO EN TRUE para ver por qué falla el pago
      ),
    );
  }
}
