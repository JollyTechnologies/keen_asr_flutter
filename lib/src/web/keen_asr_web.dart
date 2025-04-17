import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:keen_asr/keen_asr_platform_interface.dart';
import 'package:keen_asr/src/model/alternative_pronunciation.dart';
import 'package:keen_asr/src/model/asr_result.dart';
import 'package:keen_asr/src/model/speaking_task.dart';
import 'package:keen_asr/src/web/js_keen_asr.dart';
import 'package:keen_asr/src/web/js_keen_asr_wrapper.dart';
import 'package:web/web.dart';

class KeenASRWeb extends KeenASRPlatform {
  static void registerWith(Registrar registrar) {
    KeenASRPlatform.instance = KeenASRWeb();
  }

  late JSKeenASR _impl;
  late JSKeenASRWrapper _wrapper;

  @override
  Future<bool> prepare({required Uri? webSdkUri}) async {
    assert(webSdkUri != null, 'webSdkUri is required on web');

    final sdkUrl = _toAbsoluteUrl(webSdkUri!.resolve('keenasr-web.js'));
    final module = JSKeenASRModule(await importModule(sdkUrl).toDart);
    _impl = module.defaultExport;
    _wrapper = JSKeenASRWrapper(_impl);

    if (kDebugMode) {
      _wrapper.isIsolatedContext = () => true;
    }

    return await _wrapper.prepare();
  }

  @override
  Future<bool> initialize(String bundleName, {required Uri? webUri}) async {
    assert(webUri != null, 'webUri is required on web');

    if (!await _wrapper.prepare()) return false;
    if (!await _wrapper.isASRBundleAvailable(bundleName)) {
      if (!await _wrapper.fetchASRBundle(_toAbsoluteUrl(webUri!))) return false;
    }
    return await _wrapper.initialize(bundleName);
  }

  @override
  Future<bool> createDecodingGraphFromPhrases(
    List<String> phrases,
    SpeakingTask speakingTask,
    String name,
    List<AlternativePronunciation> alternativePronunciations,
  ) {
    return _wrapper.createDecodingGraphFromPhrases(
      phrases,
      alternativePronunciations.map((it) => it.toJS).toList(),
      speakingTask.toJS(_impl),
      name,
    );
  }

  @override
  Future<bool> prepareForListeningWithDecodingGraphWithName(String name, {required bool computeGop}) async =>
      _wrapper.prepareForListeningWithCustomDecodingGraphWithName(name, computeGop);

  @override
  Future<bool> startListening() async => _wrapper.startListening();

  @override
  Future<bool> stopListening() async => _wrapper.stopListening();

  @override
  void setResultHandlers({
    required void Function(ASRResult result) onPartialResult,
    required void Function(ASRResult result) onFinalResult,
  }) {
    _wrapper.setEventHandlers((it) => onPartialResult(it.toDart), (it) => onFinalResult(it.toDart), () {});
  }

  URL _toAbsoluteUrl(Uri uri) => URL(uri.toString(), window.location.href);
}

extension on SpeakingTask {
  JSSpeakingTask toJS(JSKeenASR impl) {
    return switch (this) {
      SpeakingTask.defaultTask => impl.SpeakingTask.kSpeakingTaskDefault,
      SpeakingTask.oralReading => impl.SpeakingTask.kSpeakingTaskOralReading,
    };
  }
}

extension on JSASRResult {
  ASRResult get toDart => ASRResult(text: text(), words: words().toDart.map((it) => it.toDart).toList());
}

extension on JSASRWord {
  ASRWord get toDart {
    return ASRWord(text: text, phones: phones().toDart.map((it) => it.toDart).toList());
  }
}

extension on JSASRPhone {
  ASRPhone get toDart => ASRPhone(text: text, score: score.toDartDouble);
}

extension on AlternativePronunciation {
  JSAlternativePronunciation get toJS {
    return JSAlternativePronunciation(word: text, pronunciation: pronunciation, tag: tag);
  }
}
