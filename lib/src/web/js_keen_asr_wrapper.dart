// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';

import 'package:keen_asr/src/web/js_keen_asr.dart';
import 'package:web/web.dart';

class JSKeenASRWrapper {
  final JSKeenASR _impl;

  const JSKeenASRWrapper(this._impl);

  set isIsolatedContext(bool Function() value) => _impl.isIsolatedContext = value.toJS;

  set onPartialResult(void Function(JSASRResult) value) => _impl.onPartialResult = value.toJS;

  set onFinalResponse(void Function(JSASRResponse) value) => _impl.onFinalResponse = value.toJS;

  Future<void> initialize({required URL asrBundleURL}) async {
    final params = JSASRInitializationParams(
      asrBundleURL: asrBundleURL,
      onCoreReady: () {}.toJS,
      onASRBundleReady: () {}.toJS,
    );
    await _impl.initialize(params).toDart;
  }

  Future<bool> createDecodingGraphFromPhrases(
    String name,
    List<String> phrases, {
    required JSSpeakingTask speakingTask,
    List<JSWordPronunciation>? altProns,
  }) async {
    final jsPhrases = phrases.map((it) => it.toJS).toList().toJS;
    final config = JSDecodingGraphConfig(altProns: altProns?.toJS, speakingTaskType: speakingTask);
    final jsPromise = _impl.createDecodingGraphFromPhrases(name, jsPhrases, config);
    return (await jsPromise.toDart).toDart;
  }

  Future<bool> createContextualDecodingGraphFromPhrases(
    String name,
    List<List<String>> contexts, {
    required JSSpeakingTask speakingTask,
    List<JSWordPronunciation>? altProns,
  }) async {
    final jsContexts = contexts.map((it) => it.map((it) => it.toJS).toList().toJS).toList().toJS;
    final config = JSDecodingGraphConfig(altProns: altProns?.toJS, speakingTaskType: speakingTask);
    final jsPromise = _impl.createContextualDecodingGraphFromPhrases(name, jsContexts, config);
    return (await jsPromise.toDart).toDart;
  }

  void prepareForListeningWithCustomDecodingGraphWithName(String name, bool computeGop) =>
      _impl.prepareForListeningWithDecodingGraphWithName(name, computeGop);

  void prepareForListeningWithContextualDecodingGraphWithNameAndContextId(
    String name,
    int contextId,
    bool computeGop,
  ) => _impl.prepareForListeningWithContextualDecodingGraphWithNameAndContextId(name, contextId, computeGop);

  void setVADParameters(JSVADParameters parameters) => _impl.setVADParameters(parameters);

  Future<void> startListening() async => _impl.startListening().toDart;

  Future<void> stopListening() async => _impl.stopListening().toDart;
}
