import 'package:flutter/material.dart';

class RoutineSelectionScreen extends StatelessWidget {
  const RoutineSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleccionar Ejercicios para Rutina"),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Aquí se podrán seleccionar los ejercicios de la lista para crear una rutina de entrenamiento personalizada.",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
