import 'dart:async';

import 'package:keen_asr/keen_asr.dart';
import 'package:keen_asr/src/model/keen_asr_exception.dart';

import 'keen_asr_platform_interface.dart';

export 'src/model/alternative_pronunciation.dart';
export 'src/model/asr_result.dart';
export 'src/model/speaking_task.dart';

class KeenASR {
  KeenASR._();

  static final instance = KeenASR._();

  var _isListening = false;
  void Function(ASRResult)? _onPartialResult, _onFinalResult;

  Future<void> prepare({Uri? webSdkUri}) async {
    await KeenASRException.wrap(
      operation: 'prepare()',
      () async => KeenASRPlatform.instance.prepare(webSdkUri: webSdkUri),
    );
  }

  Future<void> initialize(String bundleName, {Uri? webUri}) async {
    await KeenASRException.wrap(
      operation: 'initialize($bundleName)',
      () async => KeenASRPlatform.instance.initialize(bundleName, webUri: webUri),
    );
    KeenASRPlatform.instance.setResultHandlers(
      onPartialResult: (result) => _onPartialResult?.call(result),
      onFinalResult: (result) => _onFinalResult?.call(result),
    );
  }

  Future<void> createDecodingGraph({
    required List<String> phrases,
    required String name,
    SpeakingTask speakingTask = SpeakingTask.defaultTask,
    List<AlternativePronunciation> alternativePronunciations = const [],
  }) async {
    await KeenASRException.wrap(
      operation: 'createDecodingGraphFromPhrases($name)',
      () async => KeenASRPlatform.instance.createDecodingGraphFromPhrases(
        phrases,
        speakingTask,
        name,
        alternativePronunciations,
      ),
    );
  }

  Future<void> prepareForListeningWithDecodingGraph(String name, {bool computeGop = false}) async {
    await KeenASRException.wrap(
      operation: 'prepareForListeningWithDecodingGraph($name)',
      () async => KeenASRPlatform.instance.prepareForListeningWithDecodingGraphWithName(name, computeGop: computeGop),
    );
  }

  Stream<ASRResult> startListening() async* {
    if (_isListening) throw Exception('Already listening');
    _isListening = true;
    try {
      final stream = _createResultStream();
      await KeenASRException.wrap(operation: 'startListening()', KeenASRPlatform.instance.startListening);
      yield* stream;
    } finally {
      _onPartialResult = null;
      _onFinalResult = null;
      _isListening = false;
    }
  }

  Stream<ASRResult> _createResultStream() {
    var completed = false;
    final controller = StreamController<ASRResult>(
      onCancel: () async {
        if (completed) return;
        await KeenASRException.wrap(operation: 'stopListening()', KeenASRPlatform.instance.stopListening);
      },
    );
    _onPartialResult = controller.add;
    _onFinalResult = (result) {
      controller.add(result);
      completed = true;
      controller.close();
    };
    return controller.stream;
  }
}
