import 'package:flutter/material.dart';
import 'package:congreso_app/screens/splash_screen.dart';

/**
 * LOGIN PAGE - Punto de entrada principal para la autenticación
 * * NOTA PARA DESARROLLO BACKEND:
 * 1. Actualmente la validación es local y solo verifica que el campo no esté vacío.
 * 2. Se debe integrar aquí la llamada al ApiService para validar matrícula/usuario.
 * 3. Se bloquea el acceso a usuarios tipo 'admin' ya que esta interfaz es para alumnos.
 */
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controlador para capturar la entrada de texto del usuario (Matrícula)
  final TextEditingController _userController = TextEditingController();

  /**
   * MÉTODO: _intentarAcceso
   * Gestiona el flujo de autenticación y navegación inicial.
   */
  void _intentarAcceso() {
    String user = _userController.text.trim();

    // Validación básica de campo requerido
    if (user.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa tu usuario")),
      );
      return;
    }

    /** * LÓGICA DE NEGOCIO: 
     * Restricción de perfiles. El perfil administrativo debe usar una App distinta.
     */
    if (user.toLowerCase() == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Acceso denegado. Esta app es exclusiva para Alumnos."),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      /**
       * NAVEGACIÓN POST-LOGIN:
       * Se utiliza 'pushReplacement' para limpiar el stack de navegación y 
       * evitar que el usuario regrese al Login con el botón físico de 'atrás'.
       * Se envía el parámetro 'user' hacia el SplashScreen para personalizar la carga.
       */
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SplashScreen(
            nombreUsuario:
                user, // Dato persistido durante la sesión [cite: 2026-01-31]
          ),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Identidad Visual del Congreso/Institución
                Image.asset(
                  'assets/logo.png', // Logo institucional
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 60),

                // Campo de entrada para Matrícula/Usuario
                TextField(
                  controller: _userController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Usuario o Matrícula',
                    helperText: 'Ingresa tu credencial institucional',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 25),

                // Botón de Acción Principal
                ElevatedButton(
                  onPressed: _intentarAcceso,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "INGRESAR",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
