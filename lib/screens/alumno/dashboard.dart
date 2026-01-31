import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AlumnoDashboard extends StatelessWidget {
  const AlumnoDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Progreso"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: SingleChildScrollView( // Para que quepa todo en pantallas chicas
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("¡Hola, Carlos!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              
              // Tarjeta de la Gráfica
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 150, height: 150,
                        child: CircularProgressIndicator(
                          value: 0.3, // 3 de 10
                          strokeWidth: 12,
                          color: Colors.indigo,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const Column(
                        children: [
                          Text("30%", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          Text("Asistencia"),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
              const Text("Últimas asistencias", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Lista de Historial (Simulada)
              _historialItem("Ciberseguridad en la Nube", "10:00 AM", Colors.green),
              _historialItem("IA Generativa 2026", "12:30 PM", Colors.green),
              _historialItem("Taller de Pentesting", "Ayer", Colors.blueGrey),

              const SizedBox(height: 30),
              
              ElevatedButton.icon(
                onPressed: () {
                  // Esto abre una ventana emergente con la cámara
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7, // 70% de la pantalla
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text("Escanea el código QR del taller", 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          Expanded(
                            child: MobileScanner(
                              onDetect: (capture) {
                                final List<Barcode> barcodes = capture.barcodes;
                                for (final barcode in barcodes) {
                                  print('¡QR Encontrado!: ${barcode.rawValue}');
                    
                                  // Al detectar uno, cerramos la cámara y avisamos
                                  Navigator.pop(context); 
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Asistencia registrada: ${barcode.rawValue}")),
                                  );
                                  break; 
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("REGISTRAR NUEVA ASISTENCIA"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.indigo, // Color para que resalte
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historialItem(String titulo, String hora, Color color) {
    return ListTile(
      leading: Icon(Icons.check_circle, color: color),
      title: Text(titulo),
      subtitle: Text(hora),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}