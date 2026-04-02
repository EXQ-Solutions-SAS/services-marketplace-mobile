import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Services Marketplace',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const Scaffold(
        body: Center(child: Text('Backend listo, ¡ahora vamos por el Front!')),
      ),
    );
  }
}