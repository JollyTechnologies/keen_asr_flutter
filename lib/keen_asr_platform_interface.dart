import 'package:keen_asr/src/model/alternative_pronunciation.dart';
import 'package:keen_asr/src/model/asr_result.dart';
import 'package:keen_asr/src/model/speaking_task.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'keen_asr_method_channel.dart';

abstract class KeenASRPlatform extends PlatformInterface {
  KeenASRPlatform() : super(token: _token);

  static final _token = Object();

  static KeenASRPlatform _instance = MethodChannelKeenASR();

  static KeenASRPlatform get instance => _instance;

  static set instance(KeenASRPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> prepare({required Uri? webSdkUri});

  Future<bool> initialize(String bundleName, {required Uri? webUri});

  Future<bool> createDecodingGraphFromPhrases(
    List<String> phrases,
    SpeakingTask speakingTask,
    String name,
    List<AlternativePronunciation> alternativePronunciations,
  );

  Future<bool> prepareForListeningWithDecodingGraphWithName(String name, {required bool computeGop});

  Future<bool> startListening();

  Future<bool> stopListening();

  void setResultHandlers({
    required void Function(ASRResult result) onPartialResult,
    required void Function(ASRResult result) onFinalResult,
  });
}
