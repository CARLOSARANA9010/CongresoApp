import 'dart:math';
import 'package:flutter/material.dart';

class PlexusBackground extends StatefulWidget {
  const PlexusBackground({super.key});

  @override
  State<PlexusBackground> createState() => _PlexusBackgroundState();
}

class _PlexusBackgroundState extends State<PlexusBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Point> points = [];
  final int numberOfPoints = 35; // Ajusta según qué tan saturado lo quieras

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generar puntos iniciales aleatorios
    for (int i = 0; i < numberOfPoints; i++) {
      points.add(Point());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var point in points) {
          point.update();
        }
        return CustomPaint(painter: PlexusPainter(points), child: Container());
      },
    );
  }
}

class Point {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double vx = (Random().nextDouble() - 0.5) * 0.001;
  double vy = (Random().nextDouble() - 0.5) * 0.001;

  void update() {
    x += vx;
    y += vy;

    // Rebotar en los bordes
    if (x < 0 || x > 1) vx *= -1;
    if (y < 0 || y > 1) vy *= -1;
  }
}

class PlexusPainter extends CustomPainter {
  final List<Point> points;
  PlexusPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Definimos los pinceles PRIMERO
    final paintPoint = Paint()
      ..color = Colors.indigo.withOpacity(0.5)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    final paintGlow = Paint()
      ..color = Colors.cyan.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final paintLine = Paint()..strokeWidth = 1;

    // 2. Entramos al ciclo para recorrer los puntos
    for (int i = 0; i < points.length; i++) {
      // AQUÍ se define p1, ahora sí se puede usar abajo
      var p1 = Offset(points[i].x * size.width, points[i].y * size.height);

      // 3. Dibujamos el brillo y el punto (el orden importa: el brillo va abajo)
      canvas.drawCircle(p1, 6, paintGlow);
      canvas.drawCircle(p1, 2, paintPoint);

      // 4. Ciclo interno para las conexiones (aristas)
      for (int j = i + 1; j < points.length; j++) {
        var p2 = Offset(points[j].x * size.width, points[j].y * size.height);
        double distance = (p1 - p2).distance;

        if (distance < 150) {
          paintLine.color = Colors.indigo.withOpacity(1 - (distance / 150));
          canvas.drawLine(p1, p2, paintLine);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
