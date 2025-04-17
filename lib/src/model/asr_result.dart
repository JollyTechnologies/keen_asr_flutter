class ASRResult {
  final String text;
  final List<ASRWord> words;

  const ASRResult({required this.text, required this.words});
}

class ASRWord {
  final String text;
  final List<ASRPhone> phones;

  const ASRWord({required this.text, required this.phones});
}

class ASRPhone {
  final String text;
  final double score;

  const ASRPhone({required this.text, required this.score});
}
