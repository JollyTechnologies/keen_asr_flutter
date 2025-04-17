// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';

import 'package:keen_asr/src/web/js_keen_asr.dart';
import 'package:web/web.dart';

class JSKeenASRWrapper {
  final JSKeenASR _impl;

  const JSKeenASRWrapper(this._impl);

  set isIsolatedContext(bool Function() value) => _impl.isIsolatedContext = value.toJS;

  Future<bool> prepare() async => (await _impl.prepare().toDart).toDart;

  Future<bool> initialize(String ASRBundleName) async {
    final result = (await _impl.initialize(ASRBundleName).toDart).dartify();
    if (result is bool) return result;
    return result != 0;
  }

  Future<bool> isASRBundleAvailable(String asrBundleName) async =>
      (await _impl.isASRBundleAvailable(asrBundleName).toDart).toDart;

  Future<bool> fetchASRBundle(URL url) async => (await _impl.fetchASRBundle(url).toDart).toDart;

  Future<bool> createDecodingGraphFromPhrases(
    List<String> phrases,
    List<JSAlternativePronunciation> alternativePronunciations,
    JSSpeakingTask speakingTask,
    String name,
  ) async {
    final jsPhrases = phrases.map((it) => it.toJS).toList().toJS;
    final jsPromise = _impl.createDecodingGraphFromPhrases(
      jsPhrases,
      alternativePronunciations.toJS,
      speakingTask,
      name,
    );
    return (await jsPromise.toDart).toDart;
  }

  bool prepareForListeningWithCustomDecodingGraphWithName(String name, bool computeGop) =>
      _impl.prepareForListeningWithCustomDecodingGraphWithName(name, computeGop).toDart;

  Future<bool> startListening() async => (await _impl.startListening().toDart).toDart;

  Future<bool> stopListening() async => (await _impl.stopListening().toDart).toDart;

  void setEventHandlers(
    void Function(JSASRResult result) onPartialResult,
    void Function(JSASRResult result) onFinalResult,
    void Function() onAudioRecorded,
  ) {
    return _impl.setEventHandlers(onPartialResult.toJS, onFinalResult.toJS, onAudioRecorded.toJS);
  }
}
