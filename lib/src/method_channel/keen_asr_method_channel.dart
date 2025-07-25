import 'package:keen_asr/src/method_channel/native_keen_asr.g.dart';
import 'package:keen_asr/src/model/alternative_pronunciation.dart';
import 'package:keen_asr/src/model/asr_result.dart';
import 'package:keen_asr/src/model/speaking_task.dart';

import '../../keen_asr_platform_interface.dart';

class MethodChannelKeenASR extends KeenASRPlatform {
  final _native = NativeKeenASR();

  void Function(ASRResult)? _onPartialResult, _onFinalResult;

  MethodChannelKeenASR() {
    nativeStreamKeenASREvents().listen((it) {
      final callback = it.isFinal ? _onFinalResult : _onPartialResult;
      callback?.call(it.toDart);
    });
  }

  @override
  bool prepare({Uri? webSdkUri}) => true;

  @override
  Future<bool> initialize(String bundleName, {required Uri? webUri}) async => _native.initializeWithAsset(bundleName);

  @override
  Future<bool> createDecodingGraphFromPhrases(
    List<String> phrases,
    SpeakingTask speakingTask,
    String name,
    List<AlternativePronunciation>? alternativePronunciations,
  ) => _native.createDecodingGraphFromPhrases(phrases, speakingTask.toNative, name);

  @override
  Future<bool> prepareForListeningWithDecodingGraphWithName(String name, {required bool computeGop}) =>
      _native.prepareForListeningWithDecodingGraphWithName(name, computeGop);

  @override
  Future<bool> startListening() => _native.startListening();

  @override
  Future<bool> stopListening() => _native.stopListening();

  @override
  void setResultHandlers({
    required void Function(ASRResult result) onPartialResult,
    required void Function(ASRResult result) onFinalResult,
  }) {
    _onPartialResult = onPartialResult;
    _onFinalResult = onFinalResult;
  }
}

extension on SpeakingTask {
  NativeSpeakingTask get toNative {
    return switch (this) {
      SpeakingTask.defaultTask => NativeSpeakingTask.defaultTask,
      SpeakingTask.oralReading => NativeSpeakingTask.oralReading,
    };
  }
}

extension on NativeASREvent {
  ASRResult get toDart => ASRResult(text: text, words: words.map((it) => it.toDart).toList());
}

extension on NativeASRWord {
  ASRWord get toDart => ASRWord(text: text, phones: phones.map((it) => it.toDart).toList());
}

extension on NativeASRPhone {
  ASRPhone get toDart => ASRPhone(text: text, score: score);
}
