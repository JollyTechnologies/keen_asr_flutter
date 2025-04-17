import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:keen_asr/src/model/alternative_pronunciation.dart';
import 'package:keen_asr/src/model/asr_result.dart';
import 'package:keen_asr/src/model/speaking_task.dart';

import 'keen_asr_platform_interface.dart';

class MethodChannelKeenASR extends KeenASRPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('keen_asr');

  @override
  Future<bool> prepare({Uri? webSdkUri}) async {
    // TODO: implement prepare
    throw UnimplementedError();
  }

  @override
  Future<bool> initialize(String bundleName, {Uri? webUri}) async {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<bool> createDecodingGraphFromPhrases(
    List<String> phrases,
    SpeakingTask speakingTask,
    String name,
    List<AlternativePronunciation>? alternativePronunciations,
  ) {
    // TODO: implement createDecodingGraphFromPhrases
    throw UnimplementedError();
  }

  @override
  Future<bool> prepareForListeningWithDecodingGraphWithName(String name, {required bool computeGop}) {
    // TODO: implement prepareForListeningWithDecodingGraphWithName
    throw UnimplementedError();
  }

  @override
  Future<bool> startListening() {
    // TODO: implement startListening
    throw UnimplementedError();
  }

  @override
  Future<bool> stopListening() {
    // TODO: implement stopListening
    throw UnimplementedError();
  }

  @override
  void setResultHandlers({
    required void Function(ASRResult result) onPartialResult,
    required void Function(ASRResult result) onFinalResult,
  }) {
    // TODO: implement setResultHandlers
  }
}
