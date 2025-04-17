class AlternativePronunciation {
  final String text;
  final String pronunciation;
  final String? tag;

  const AlternativePronunciation({
    required this.text,
    required this.pronunciation,
    this.tag,
  });
}