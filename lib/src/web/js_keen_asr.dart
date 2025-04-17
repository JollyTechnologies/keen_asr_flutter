// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';

import 'package:web/web.dart';

extension type JSKeenASRModule(JSObject _) implements JSObject {
  @JS('default')
  external JSKeenASR get defaultExport;
}

extension type JSKeenASR._(JSObject _) implements JSObject {
  external JSSpeakingTask get SpeakingTask;

  external JSFunction isIsolatedContext;

  external JSPromise<JSBoolean> prepare();

  external JSPromise<JSAny> initialize(String bundleName);

  external JSPromise<JSBoolean> isASRBundleAvailable(String bundleName);

  external JSPromise<JSBoolean> fetchASRBundle(URL url);

  external JSPromise<JSBoolean> createDecodingGraphFromPhrases(
    JSArray<JSString> phrases,
    JSArray<JSAlternativePronunciation> alternativePronunciations,
    JSSpeakingTask speakingTask,
    String name,
  );

  external JSBoolean prepareForListeningWithCustomDecodingGraphWithName(String name, bool computeGop);

  external JSPromise<JSBoolean> startListening();

  external JSPromise<JSBoolean> stopListening();

  external JSVoid setEventHandlers(JSFunction onPartialResult, JSFunction onFinalResult, JSFunction onAudioRecorded);
}

extension type JSSpeakingTask._(JSObject _) implements JSObject {
  external final JSSpeakingTask kSpeakingTaskDefault;
  external final JSSpeakingTask kSpeakingTaskOralReading;
}

extension type JSASRResult._(JSObject _) implements JSObject {
  external String text();

  external JSArray<JSASRWord> words();
}

extension type JSASRWord._(JSObject _) implements JSObject {
  external String get text;

  external JSArray<JSASRPhone> phones();
}

extension type JSASRPhone._(JSObject _) implements JSObject {
  external String get text;

  external JSNumber get score;
}

extension type JSAlternativePronunciation._(JSObject _) implements JSObject {
  external factory JSAlternativePronunciation({required String word, required String pronunciation, String? tag});
}
