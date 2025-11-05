import 'package:flutter/material.dart';

class ExerciseInputScreen extends StatelessWidget {
  const ExerciseInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingresar Ejercicio"),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Aquí se podrán ingresar nuevos ejercicios a la base de datos de la aplicación.",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
