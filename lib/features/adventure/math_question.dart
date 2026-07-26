class MathQuestion {
  const MathQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.hints,
    required this.explanation,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final List<String> hints;
  final String explanation;
}
