import 'package:flutter/material.dart';
import 'package:congreso_app/screens/admin/staff_view.dart'; 
import 'package:congreso_app/screens/alumno/dashboard.dart';


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

    if (user.toLowerCase() == 'admin') {
      // 1. Caso Admin
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StaffView()),
      );
    } else if (user.isNotEmpty) {
      // 2. Caso Alumno: PRIMERO navegamos, LUEGO saludamos
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AlumnoDashboard()),
      );
      
      // Opcional: Mostrar el mensaje ya estando en la otra pantalla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bienvenido Alumno: $user")),
      );
    } else {
      // 3. Caso Vacío
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa tu usuario")),
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