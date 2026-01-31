import 'package:flutter/material.dart';
import 'package:congreso_app/screens/login_page.dart';

void main() => runApp(const CongresoApp());

class CongresoApp extends StatelessWidget {
  const CongresoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const LoginPage(),
    );
  }
}

