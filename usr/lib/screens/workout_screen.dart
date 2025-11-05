import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/exercise.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // Datos de ejemplo para la rutina
  final List<Exercise> _routine = [
    Exercise(
      name: "Flexiones",
      imageUrl: "https://i.imgur.com/v0T5I0G.png", 
      sets: 3,
      reps: 12,
      restBetweenSets: const Duration(seconds: 60),
    ),
    Exercise(
      name: "Plancha",
      imageUrl: "https://i.imgur.com/s1Jd3Gz.png",
      sets: 3,
      duration: const Duration(seconds: 45),
      restBetweenSets: const Duration(seconds: 60),
    ),
    Exercise(
      name: "Sentadillas",
      imageUrl: "https://i.imgur.com/d2zB9aN.png",
      sets: 3,
      reps: 15,
      restBetweenSets: const Duration(seconds: 60),
    ),
  ];

  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  Timer? _timer;
  int _countdown = 5;
  String _currentState = "START"; // START, GET_READY, WORK, REST, DONE
  Duration? _currentTime;

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _setupTts();
  }

  void _setupTts() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startWorkout() {
    setState(() {
      _currentState = "GET_READY";
      _countdown = 5; // 5 segundos de cuenta regresiva
    });
    _speak("Prepárate. Empezamos en $_countdown segundos.");
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _startExercise();
      }
    });
  }

  void _startExercise() {
    final currentExercise = _routine[_currentExerciseIndex];
    _speak("Empezamos con ${currentExercise.name}");

    setState(() {
      _currentState = "WORK";
      if (currentExercise.duration != null) {
        _currentTime = currentExercise.duration;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_currentTime!.inSeconds > 1) {
            setState(() {
              _currentTime = Duration(seconds: _currentTime!.inSeconds - 1);
            });
          } else {
            timer.cancel();
            _startRest();
          }
        });
      }
    });
  }

  void _startRest() {
    if (_currentSet < _routine[_currentExerciseIndex].sets) {
      final restDuration = _routine[_currentExerciseIndex].restBetweenSets;
      _speak("Descansa.");
      setState(() {
        _currentState = "REST";
        _currentTime = restDuration;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_currentTime!.inSeconds > 1) {
          setState(() {
            _currentTime = Duration(seconds: _currentTime!.inSeconds - 1);
          });
        } else {
          timer.cancel();
          setState(() {
            _currentSet++;
          });
          _startExercise();
        }
      });
    } else {
      _moveToNextExercise();
    }
  }

  void _moveToNextExercise() {
    if (_currentExerciseIndex < _routine.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
      });
      _startWorkout(); // Inicia la cuenta regresiva para el siguiente ejercicio
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() {
    _speak("¡Felicidades! Has completado la rutina.");
    setState(() {
      _currentState = "DONE";
    });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildStartView() {
    return Center(
      child: ElevatedButton(
        onPressed: _startWorkout,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        ),
        child: const Text("Empezar Rutina", style: TextStyle(fontSize: 24)),
      ),
    );
  }

  Widget _buildGetReadyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("¡Prepárate!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text(_countdown.toString(), style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWorkoutView() {
    final exercise = _routine[_currentExerciseIndex];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("Set $_currentSet / ${exercise.sets}", style: const TextStyle(fontSize: 24)),
        Text(exercise.name, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        Image.network(exercise.imageUrl, height: 250, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 250)),
        if (exercise.duration != null)
          Text(_formatDuration(_currentTime), style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold))
        else
          Text("${exercise.reps} Reps", style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold)),
        
        if (exercise.reps != null)
          ElevatedButton(
            onPressed: _startRest,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
            child: const Text("Hecho", style: TextStyle(fontSize: 20)),
          ),
      ],
    );
  }

  Widget _buildRestView() {
    final nextExerciseName = (_currentSet < _routine[_currentExerciseIndex].sets)
        ? _routine[_currentExerciseIndex].name
        : (_currentExerciseIndex + 1 < _routine.length)
            ? _routine[_currentExerciseIndex + 1].name
            : "Fin";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Descanso", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text(_formatDuration(_currentTime), style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text("Siguiente: $nextExerciseName", style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildDoneView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("¡Rutina Completada!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentExerciseIndex = 0;
                _currentSet = 1;
                _currentState = "START";
              });
            },
            child: const Text("Empezar de Nuevo"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentView;
    switch (_currentState) {
      case "GET_READY":
        currentView = _buildGetReadyView();
        break;
      case "WORK":
        currentView = _buildWorkoutView();
        break;
      case "REST":
        currentView = _buildRestView();
        break;
      case "DONE":
        currentView = _buildDoneView();
        break;
      case "START":
      default:
        currentView = _buildStartView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Rutina de Entrenamiento"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: currentView,
      ),
    );
  }
}
