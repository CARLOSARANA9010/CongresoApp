import 'package:flutter/material.dart';
import 'package:congreso_app/screens/splash_screen.dart';
import 'package:congreso_app/data/models/alumno_model.dart';
import 'package:congreso_app/data/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  bool _isLoading = false; // Para mostrar el progreso de carga, supongo

  /**
   * MÉTODO: _intentarAcceso
   * Ahora es ASÍNCRONO para conectar con NocoDB.
   */
  Future<void> _intentarAcceso() async {
    String email = _userController.text.trim();

    if (email.isEmpty) {
      _mostrarMensaje("Por favor ingresa tu correo institucional");
      return;
    }

    if (email.toLowerCase() == 'admin') {
      _mostrarMensaje(
        "Acceso denegado. App exclusiva para Alumnos.",
        color: Colors.orange,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // LLAMADA REAL A NOCODB PARA VERIFICAR EL USUARIO
      final ApiService api = ApiService();
      final Alumno? alumnoEncontrado = await api.loginAlumno(email);

      if (alumnoEncontrado != null) {
        // ¡ÉXITO! Navegamos con los datos reales del ITESCAM
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SplashScreen(alumno: alumnoEncontrado),
          ),
        );
      } else {
        _mostrarMensaje("Usuario no encontrado. Revisa tu correo.");
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión. Intenta más tarde.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarMensaje(String msg, {Color color = Colors.redAccent}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 60),

                TextField(
                  controller: _userController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Institucional',
                    helperText: 'Usa el correo con el que te registraste',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 25),

                // BOTÓN DINÁMICO: Muestra carga o el texto de ingresar
                ElevatedButton(
                  onPressed: _isLoading ? null : _intentarAcceso,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "INGRESAR",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
