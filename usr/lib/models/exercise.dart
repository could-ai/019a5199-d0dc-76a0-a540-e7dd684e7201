class Exercise {
  final String name;
  final String imageUrl;
  final int sets;
  final int? reps;
  final Duration? duration;
  final Duration restBetweenSets;

  Exercise({
    required this.name,
    required this.imageUrl,
    required this.sets,
    this.reps,
    this.duration,
    required this.restBetweenSets,
  });
}
