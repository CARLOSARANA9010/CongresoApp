import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:congreso_app/screens/alumno/main_screen.dart'; // Tu ruta

class SplashScreen extends StatefulWidget {
  final String nombreUsuario;
  const SplashScreen({super.key, required this.nombreUsuario});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // CONTROLADOR PRINCIPAL: 25 segundos para el fondo LENTO
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    // Tiempo de carga (5 segundos es perfecto)
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MainScreen(nombreUsuario: widget.nombreUsuario),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. FONDO: Gradiente profundo Negro/Indigo
          Container(color: const Color(0xFF000520)),

          // 2. ANIMACIÓN DE FONDO: Lava Tech Lenta (25s)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: LavaPainter(_controller.value),
                child: Container(),
              );
            },
          ),

          // 3. CONTENIDO CENTRAL
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ITESCAM (itescam_logo.png)
                  Image.asset(
                    'assets/itescam_logo.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),

                  // Texto Hecho por ITESCAM
                  const Text(
                    "Hecho por estudiantes del ITESCAM",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.cyanAccent, blurRadius: 15),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Nombres: Carlos Arana y Manuel Orlando
                  const Text(
                    "Carlos Arana y Manuel Orlando",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 70), // Espacio para el cargador
                  // --- EL HEXÁGONO DE HEXÁGONOS ÉPICO (RÁPIDO) ---
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: HexOfHexAssemblerPainter(_controller.value),
                        child: const SizedBox(height: 100, width: 100),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor de Lava (Fondo Lento - 25s)
class LavaPainter extends CustomPainter {
  final double animationValue;
  LavaPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    for (int i = 0; i < 6; i++) {
      // Movimiento lento basado en animationValue puro
      final double x =
          size.width *
          (random.nextDouble() + sin(animationValue * 2.0 * pi + i) * 0.15);
      final double y =
          size.height *
          (random.nextDouble() + cos(animationValue * 2.0 * pi + i) * 0.15);
      final paint = Paint()
        ..color = Colors.indigo.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
      canvas.drawCircle(Offset(x, y), 90, paint);
    }
  }

  @override
  bool shouldRepaint(LavaPainter oldDelegate) => true;
}

// --- EL PINTOR DEL HEXÁGONO DE HEXÁGONOS (RÁPIDO) ---
class HexOfHexAssemblerPainter extends CustomPainter {
  final double animationValue;
  HexOfHexAssemblerPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // ACELERACIÓN: Multiplicamos el valor de animación para que el ciclo de carga
    // ocurra muchas veces mientras el fondo apenas se mueve (8 veces más rápido)
    double fastTime = (animationValue * 12.0) % 1.0;

    // Tamaño de cada hexágono individual
    const double hexRadius = 18.0;

    // Pintura base Cian Neón
    final paintBase = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Pintura para Glow
    final paintGlow = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Definimos las posiciones finales para formar un Hexágono de Hexágonos
    // (1 central + 6 alrededor)
    final List<Offset> targets = [
      const Offset(0, 0), // Centro
      Offset(0, -hexRadius * 1.5), // Arriba
      Offset(0, hexRadius * 1.5), // Abajo
      Offset(hexRadius * 1.3, -hexRadius * 0.75), // Derecha Arriba
      Offset(hexRadius * 1.3, hexRadius * 0.75), // Derecha Abajo
      Offset(-hexRadius * 1.3, -hexRadius * 0.75), // Izquierda Arriba
      Offset(-hexRadius * 1.3, hexRadius * 0.75), // Izquierda Abajo
    ];

    // Definimos las posiciones iniciales (Fuera de la pantalla)
    final List<Offset> starts = [
      const Offset(0, -200),
      const Offset(200, 0),
      const Offset(-200, 0),
      const Offset(200, -200),
      const Offset(200, 200),
      const Offset(-200, -200),
      const Offset(-200, 200),
    ];

    for (int i = 0; i < targets.length; i++) {
      // Retraso individual para el ensamblado secuencial (0.0 a 1.0)
      double individualT = (fastTime * 2.0 - (i * 0.1)).clamp(0.0, 1.0);

      // Curva de llegada con rebote elástico (Muy rápida y épica)
      double curve = Curves.elasticOut.transform(individualT);

      Offset pos = Offset.lerp(center + starts[i], center + targets[i], curve)!;

      // Interpolación de escala y opacidad
      final double opacity = lerpDouble(0.1, 1.0, curve)!;
      final double scale = lerpDouble(0.5, 1.0, curve)!;

      if (opacity > 0.2) {
        _drawHexagon(
          canvas,
          pos,
          hexRadius * scale,
          paintFill: paintGlow,
          paintStroke: paintBase,
        );
      }
    }
  }

  // Función auxiliar para dibujar un hexágono plano
  void _drawHexagon(
    Canvas canvas,
    Offset center,
    double radius, {
    required Paint paintFill,
    required Paint paintStroke,
  }) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * pi / 180;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();

    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
  }

  double? lerpDouble(num a, num b, double t) {
    return a + (b - a) * t;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
