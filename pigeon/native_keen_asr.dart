@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/method_channel/native_keen_asr.g.dart',
    kotlinOut: 'android/src/main/kotlin/com/keenresearch/keenasr/flutter/NativeKeenASR.g.kt',
    kotlinOptions: KotlinOptions(package: "com.keenresearch.keenasr.flutter"),
    swiftOut: 'ios/Classes/NativeKeenASR.g.swift',
    dartPackageName: "keen_asr",
  ),
)
library;

import 'package:pigeon/pigeon.dart';

enum NativeSpeakingTask { defaultTask, oralReading }

enum NativeVADParameter {
  timeoutEndSilenceForAnyMatch,
  timeoutEndSilenceForGoodMatch,
  timeoutForNoSpeech,
  timeoutMaxDuration,
}

class NativeASREvent {
  final String text;
  final List<NativeASRWord> words;
  final bool isFinal;

  const NativeASREvent({required this.text, required this.words, required this.isFinal});
}

class NativeASRWord {
  final String text;
  final List<NativeASRPhone> phones;

  const NativeASRWord({required this.text, required this.phones});
}

class NativeASRPhone {
  final String text;
  final double score;

  const NativeASRPhone({required this.text, required this.score});
}

class NativeAlternativePronunciation {
  final String text;
  final String pronunciation;
  final String? tag;

  const NativeAlternativePronunciation({required this.text, required this.pronunciation, required this.tag});
}

@HostApi()
abstract class NativeKeenASR {
  @async
  bool initializeWithAsset(String bundleName);

  @async
  void setVADParameter(NativeVADParameter parameter, double value);

  @async
  bool createDecodingGraphFromPhrases(
    List<String> phrases,
    NativeSpeakingTask speakingTask,
    String name,
    List<NativeAlternativePronunciation> alternativePronunciations,
    double spokenNoiseProbability,
  );

  @async
  bool createContextualDecodingGraphFromPhrases(
    List<List<String>> contextualPhrases,
    NativeSpeakingTask speakingTask,
    String name,
    List<NativeAlternativePronunciation> alternativePronunciations,
    double spokenNoiseProbability,
  );

  @async
  bool prepareForListeningWithDecodingGraphWithName(String name, bool computeGop);

  @async
  bool prepareForListeningWithContextualDecodingGraphWithName(String name, int contextId, bool computeGop);

  @async
  bool startListening();

  @async
  bool stopListening();
}

@EventChannelApi()
abstract class NativeKeenASREvents {
  NativeASREvent nativeStreamKeenASREvents();
}
