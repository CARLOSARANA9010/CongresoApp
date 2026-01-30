import 'package:flutter/material.dart';

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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();

  void _intentarAcceso() {
    String user = _userController.text.trim();

    if (user.toLowerCase() == 'admin') {
      // Navegar a Vista Staff (Pendiente de crear archivo)
      print("Entrando como Admin...");
    } else if (user.isNotEmpty) {
      // Navegar a Vista Alumno (Pendiente de crear archivo)
      print("Entrando como Alumno: $user");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa tu matrícula")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text("CiberIA 2026", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: 'Matrícula o Usuario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _intentarAcceso,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text("INICIAR SESIÓN"),
            ),
          ],
        ),
      ),
    );
  }
}