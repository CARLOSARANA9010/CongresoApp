import 'package:flutter/material.dart';
import 'package:congreso_app/screens/auth/login_page.dart';

/**
 * PUNTO DE ENTRADA PRINCIPAL - Congreso App ITESCAM
 * * NOTA PARA DESARROLLO:
 * 1. Aquí se inicializa la configuración global de la aplicación.
 * 2. El tema utiliza Material 3 con el color índigo como semilla institucional [cite: 2026-02-27].
 * 3. La navegación comienza siempre en 'LoginPage' para asegurar la autenticación [cite: 2026-02-27].
 */
void main() => runApp(const CongresoApp());

class CongresoApp extends StatelessWidget {
  const CongresoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Desactiva el banner de depuración en la esquina superior derecha
      debugShowCheckedModeBanner: false,

      // CONFIGURACIÓN ESTÉTICA:
      // Se define el esquema de colores basado en los requerimientos del ITESCAM.
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness
            .light, // Puede cambiarse a dark según la preferencia del usuario
      ),

      /**
       * RUTA INICIAL:
       * La aplicación inicia en la pantalla de Login.
       * Una vez validado el usuario, el flujo pasará al SplashScreen y luego al MainScreen.
       */
      home: const LoginPage(),
    );
  }
}
