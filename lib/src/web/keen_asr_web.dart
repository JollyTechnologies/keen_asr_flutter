import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:keen_asr/keen_asr.dart';
import 'package:keen_asr/keen_asr_platform_interface.dart';
import 'package:keen_asr/src/model/vad_parameter.dart';
import 'package:keen_asr/src/web/js_keen_asr.dart';
import 'package:keen_asr/src/web/js_keen_asr_wrapper.dart';
import 'package:web/web.dart';

class KeenASRWeb extends KeenASRPlatform {
  static void registerWith(Registrar registrar) {
    KeenASRPlatform.instance = KeenASRWeb();
  }

  late JSKeenASRModule _module;
  late JSKeenASR _impl;
  late JSKeenASRWrapper _wrapper;

  @override
  Future<void> prepare({required Uri? webSdkUri}) async {
    assert(webSdkUri != null, 'webSdkUri is required on web');

    final sdkUrl = _toAbsoluteUrl(webSdkUri!.resolve('keenasr-web.js'));
    _module = JSKeenASRModule(await importModule(sdkUrl).toDart);
    _impl = _module.defaultExport;
    _wrapper = JSKeenASRWrapper(_impl);

    if (kDebugMode) {
      _wrapper.isIsolatedContext = () => true;
      globalContext['KeenASR'] = _module;
    }
  }

  @override
  Future<bool> initialize(String bundleName, {required Uri? webUri}) async {
    assert(webUri != null, 'webUri is required on web');

    await _wrapper.initialize(asrBundleURL: _toAbsoluteUrl(webUri!));
    return true;
  }

  @override
  Future<void> setVADParameter(VADParameter parameter, double value) async {
    final parameters = switch (parameter) {
      VADParameter.timeoutForNoSpeech => JSVADParameters(timeoutForNoSpeech: value),
      VADParameter.timeoutEndSilenceForGoodMatch => JSVADParameters(timeoutEndSilenceForGoodMatch: value),
      VADParameter.timeoutEndSilenceForAnyMatch => JSVADParameters(timeoutEndSilenceForAnyMatch: value),
      VADParameter.timeoutMaxDuration => JSVADParameters(timeoutMaxDuration: value),
    };
    _wrapper.setVADParameters(parameters);
  }

  @override
  Future<bool> createDecodingGraphFromPhrases(
    List<String> phrases,
    SpeakingTask speakingTask,
    String name,
    List<AlternativePronunciation> alternativePronunciations,
  ) {
    return _wrapper.createDecodingGraphFromPhrases(
      name,
      phrases,
      speakingTask: speakingTask.toJS(_impl),
      altProns: alternativePronunciations.toJS(_module),
    );
  }

  @override
  Future<bool> createContextualDecodingGraphFromPhrases(
    List<List<String>> contextualPhrases,
    SpeakingTask speakingTask,
    String name,
    List<AlternativePronunciation> alternativePronunciations,
  ) {
    return _wrapper.createContextualDecodingGraphFromPhrases(
      name,
      contextualPhrases,
      speakingTask: speakingTask.toJS(_impl),
      altProns: alternativePronunciations.toJS(_module),
    );
  }

  @override
  Future<bool> prepareForListeningWithDecodingGraphWithName(String name, {required bool computeGop}) async {
    _wrapper.prepareForListeningWithCustomDecodingGraphWithName(name, computeGop);
    return true;
  }

  @override
  Future<bool> prepareForListeningWithContextualDecodingGraphWithName(
    String name,
    int contextId, {
    required bool computeGop,
  }) async {
    _wrapper.prepareForListeningWithContextualDecodingGraphWithNameAndContextId(name, contextId, computeGop);
    return true;
  }

  @override
  Future<bool> startListening() async {
    await _wrapper.startListening();
    return true;
  }

  @override
  Future<bool> stopListening() async {
    await _wrapper.stopListening();
    return true;
  }

  @override
  void setResultHandlers({
    required void Function(ASRResult result) onPartialResult,
    required void Function(ASRResult result) onFinalResult,
  }) {
    _wrapper.onPartialResult = (it) => onPartialResult(it.toDart);
    _wrapper.onFinalResponse = (it) => onFinalResult(it.asrResult.toDart);
  }

  URL _toAbsoluteUrl(Uri uri) => URL(uri.toString(), window.location.href);
}

extension on SpeakingTask {
  JSSpeakingTask toJS(JSKeenASR impl) {
    return switch (this) {
      SpeakingTask.defaultTask => impl.SpeakingTask.DEFAULT,
      SpeakingTask.oralReading => impl.SpeakingTask.ORAL_READING,
    };
  }
}

extension on AlternativePronunciation {
  JSWordPronunciation toJS(JSKeenASRModule module) => module.WordPronunciation(text, pronunciation, tag);
}

extension on List<AlternativePronunciation> {
  List<JSWordPronunciation> toJS(JSKeenASRModule module) => map((it) => it.toJS(module)).toList();
}

extension on JSASRResult {
  ASRResult get toDart {
    final wordsList = words?.toDart.map((it) => it.toDart).toList() ?? [];
    return ASRResult(text: text, words: wordsList);
  }
}

extension on JSASRWord {
  ASRWord get toDart {
    return ASRWord(text: text, phones: phones.toDart.map((it) => it.toDart).toList());
  }
}

extension on JSASRPhone {
  ASRPhone get toDart => ASRPhone(text: text, score: pronunciationScore);
}
