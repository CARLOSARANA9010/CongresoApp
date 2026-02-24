import 'package:flutter/material.dart';

import 'package:congreso_app/screens/alumno/main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controlador para obtener el texto que el usuario escribe
  final TextEditingController _userController = TextEditingController();

  void _intentarAcceso() {
    String user = _userController.text.trim();

    if (user.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa tu usuario")),
      );
      return;
    }

    if (user.toLowerCase() == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Acceso denegado. Esta app es exclusiva para Alumnos."),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      // PASAMOS EL NOMBRE a la siguiente pantalla
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(nombreUsuario: user),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 40),
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario o Matrícula',
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
                  child: const Text("INGRESAR"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
