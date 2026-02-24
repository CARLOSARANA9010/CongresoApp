import 'package:flutter/material.dart';

class CardProgreso extends StatelessWidget {
  final double porcentaje; // Valor de 0.0 a 1.0
  final String titulo;
  final String subtitulo;
  final Color colorPrincipal;

  const CardProgreso({
    super.key,
    required this.porcentaje,
    required this.titulo,
    required this.subtitulo,
    this.colorPrincipal = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      // Sin decoración de fondo para que sea transparente como pediste
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // El círculo de progreso
          SizedBox(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              value: porcentaje,
              strokeWidth: 12,
              color: colorPrincipal,
              backgroundColor: colorPrincipal.withOpacity(0.1),
            ),
          ),
          // El texto central
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitulo,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
