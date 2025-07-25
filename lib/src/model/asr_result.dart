class ASRResult {
  final String text;
  final List<ASRWord> words;

  const ASRResult({required this.text, required this.words});

  @override
  String toString() => "ASRResult(text: $text, words: ${words.join(" ")})";
}

class ASRWord {
  final String text;
  final List<ASRPhone> phones;

  const ASRWord({required this.text, required this.phones});

  @override
  String toString() => "ASRWord(text: $text, phones: ${phones.join(" ")})";

}

class ASRPhone {
  final String text;
  final double score;

  const ASRPhone({required this.text, required this.score});

  @override
  String toString() => "ASRPhone(text: $text, score: $score)";
}
