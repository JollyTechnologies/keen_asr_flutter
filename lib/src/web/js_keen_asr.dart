// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart';

extension type JSKeenASRModule(JSObject _) implements JSObject {
  @JS('default')
  external JSKeenASR get defaultExport;

  JSWordPronunciation WordPronunciation(String word, String pronunciation, [String? tag]) =>
      _WordPronunciation.callAsConstructorVarArgs([word.toJS, pronunciation.toJS, if (tag != null) tag.toJS]);

  @JS('WordPronunciation')
  external JSFunction get _WordPronunciation;
}

extension type JSKeenASR._(JSObject _) implements JSObject {
  external JSSpeakingTask get SpeakingTask;

  external JSFunction isIsolatedContext;

  external JSFunction onPartialResult, onFinalResponse;

  external JSPromise initialize(JSASRInitializationParams params);

  external JSPromise<JSBoolean> createDecodingGraphFromPhrases(
    String name,
    JSArray<JSString> phrases,
    JSDecodingGraphConfig config,
  );

  external JSPromise<JSBoolean> createContextualDecodingGraphFromPhrases(
    String name,
    JSArray<JSArray<JSString>> contexts,
    JSDecodingGraphConfig config,
  );

  external void prepareForListeningWithDecodingGraphWithName(String name, [bool? computeGop]);

  external void prepareForListeningWithContextualDecodingGraphWithNameAndContextId(
    String name,
    int contextId, [
    bool? computeGop,
  ]);

  external JSPromise startListening();

  external JSPromise stopListening();

  external JSVoid setVADParameters(JSVADParameters parameters);
}

extension type JSSpeakingTask._(JSObject _) implements JSObject {
  external final JSSpeakingTask DEFAULT;
  external final JSSpeakingTask ORAL_READING;
}

extension type JSASRInitializationParams._(JSObject _) implements JSObject {
  external JSASRInitializationParams({
    required URL asrBundleURL,
    bool? doEchoCancellation,
    required JSFunction onCoreReady,
    required JSFunction onASRBundleReady,
  });
}

extension type JSDecodingGraphConfig._(JSObject _) implements JSObject {
  external JSDecodingGraphConfig({
    JSArray<JSWordPronunciation>? altProns,
    required JSSpeakingTask speakingTaskType,
    double? spokenNoiseProb,
  });
}

extension type JSASRResult._(JSObject _) implements JSObject {
  external String get text;

  external JSArray<JSASRWord>? get words;
}

extension type JSASRWord._(JSObject _) implements JSObject {
  external String get text;

  external JSArray<JSASRPhone> get phones;
}

extension type JSASRPhone._(JSObject _) implements JSObject {
  external String get text;

  external double get pronunciationScore;
}

extension type JSASRResponse._(JSObject _) implements JSObject {
  external JSASRResult get asrResult;
}

extension type JSVADParameters._(JSObject _) implements JSObject {
  external JSVADParameters({
    double? timeoutForNoSpeech,
    double? timeoutEndSilenceForGoodMatch,
    double? timeoutEndSilenceForAnyMatch,
    double? timeoutMaxDuration,
  });
}

extension type JSWordPronunciation._(JSObject _) implements JSObject {}
