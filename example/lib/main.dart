import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keen_asr/keen_asr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

const _phrases = ["cow is red", "cow is black", "dupa dupa", "secretary"];

const _alternativePronunciations = [AlternativePronunciation(text: "COW", pronunciation: "K AO", tag: "variant1")];

class _MyAppState extends State<MyApp> {
  ASRResult? _result;
  bool _isReady = false;
  final _keenAsrPlugin = KeenASR.instance;
  StreamSubscription<ASRResult>? _subscription;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: _buildContent()),
        floatingActionButton: FloatingActionButton(onPressed: _startListening, child: Icon(Icons.mic)),
      ),
    );
  }

  Widget _buildContent() {
    if (!_isReady) return CircularProgressIndicator();
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text("Phrases:"),
        for (final phrase in _phrases) Text(phrase),
        const SizedBox(height: 30),
        if (_subscription != null) Text("Listening...") else if (_result == null) Text("Not started"),
        if (_result != null) ...[
          Text(_result!.text),
          for (final word in _result!.words)
            Text("${word.text} (${word.phones.map((it) => "${it.text} - ${it.score.toStringAsFixed(2)}").join(" ")})"),
        ],
      ],
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initPlatformState() async {
    await _keenAsrPlugin.prepare(webSdkUri: Uri.parse("/keenasr-0.4.8/"));
    await _keenAsrPlugin.initialize('keenAK1m-nnet3chain-en-us', webUri: Uri.parse("/keenAK1m-nnet3chain-en-us.tgz"));
    await _keenAsrPlugin.createDecodingGraph(
      phrases: _phrases,
      name: "default",
      speakingTask: SpeakingTask.oralReading,
      alternativePronunciations: _alternativePronunciations,
    );
    await _keenAsrPlugin.prepareForListeningWithDecodingGraph("default", computeGop: true);
    setState(() => _isReady = true);
  }

  Future<void> _startListening() async {
    await _subscription?.cancel();
    setState(() {
      _subscription = _keenAsrPlugin.startListening().listen(
        (result) => setState(() => _result = result),
        onDone: () => setState(() => _subscription = null),
      );
    });
  }
}
