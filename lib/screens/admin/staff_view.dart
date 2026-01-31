import 'package:flutter/material.dart';

class StaffView extends StatefulWidget {
  const StaffView({super.key});

  @override
  State<StaffView> createState() => _StaffViewState();
}

class _StaffViewState extends State<StaffView> {
  // Lista temporal de ponentes (Luego vendrá de la DB)
  final List<Map<String, dynamic>> _ponentes = [
    {"nombre": "Dr. Alan Turing", "tema": "IA en 2026", "estatus": "Confirmado", "llego": false},
    {"nombre": "Mtra. Ada Lovelace", "tema": "Ciberseguridad Proactiva", "estatus": "En camino", "llego": true},
    {"nombre": "Ing. Kevin Mitnick", "tema": "Ingeniería Social", "estatus": "Confirmado", "llego": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logística de Ponentes"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo.withOpacity(0.1),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.indigo),
                SizedBox(width: 10),
                Expanded(child: Text("Marque al ponente una vez que se encuentre en el recinto.")),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _ponentes.length,
              itemBuilder: (context, index) {
                final ponente = _ponentes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: CheckboxListTile(
                    title: Text(ponente['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${ponente['tema']}\nEstado: ${ponente['estatus']}"),
                    isThreeLine: true,
                    value: ponente['llego'],
                    secondary: CircleAvatar(
                      backgroundColor: ponente['llego'] ? Colors.green : Colors.grey,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    onChanged: (bool? value) {
                      setState(() {
                        ponente['llego'] = value!;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}