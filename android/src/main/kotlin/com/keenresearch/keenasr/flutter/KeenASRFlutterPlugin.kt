package com.keenresearch.keenasr.flutter

import com.keenresearch.keenasr.*
import com.keenresearch.keenasr.KASRDecodingGraph.KASRSpeakingTask
import com.keenresearch.keenasr.flutter.util.launchPigeon
import com.utopiaultimate.flutter.utopia_platform_utils.flutter.plugin.BaseFlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class KeenASRFlutterPlugin : BaseFlutterPlugin(), NativeKeenASR {
    private val recognizer get() = KASRRecognizer.sharedInstance()
    private var listener: KASRRecognizerListener? = null

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        super.onAttachedToEngine(binding)
        NativeKeenASR.setUp(binding.binaryMessenger, this)
        NativeStreamKeenASREventsStreamHandler.register(binding.binaryMessenger, createEventsHandler())
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        super.onDetachedFromEngine(binding)
        KASRRecognizer.teardown()
    }

    private fun createEventsHandler() = object : NativeStreamKeenASREventsStreamHandler() {
        override fun onListen(p0: Any?, sink: PigeonEventSink<NativeASREvent>) {
            listener = object : KASRRecognizerListener {
                override fun onPartialResult(p0: KASRRecognizer, p1: KASRResult) = onEvent(p1, isFinal = false)

                override fun onFinalResponse(p0: KASRRecognizer, p1: KASRResponse) =
                    onEvent(p1.asrResult, isFinal = true)

                private fun onEvent(result: KASRResult, isFinal: Boolean) {
                    launch(Dispatchers.Main) { sink.success(result.toDart(isFinal)) }
                }
            }
        }
    }

    override fun initializeWithAsset(bundleName: String, callback: (Result<Boolean>) -> Unit) =
        launchPigeon(callback, Dispatchers.IO) {
            KASRBundle(context).installASRBundle(bundleName, context.cacheDir.path) || return@launchPigeon false
            KASRRecognizer.initWithASRBundleAtPath(context.cacheDir.resolve(bundleName).path, context)
                    || return@launchPigeon false
            recognizer.addListener(listener)
            return@launchPigeon true
        }

    override fun createDecodingGraphFromPhrases(
        phrases: List<String>,
        speakingTask: NativeSpeakingTask,
        name: String,
        callback: (Result<Boolean>) -> Unit
    ) = launchPigeon(callback, Dispatchers.IO) {
        KASRDecodingGraph.createDecodingGraphFromPhrases(
            phrases.toTypedArray(),
            recognizer,
            arrayListOf(),
            speakingTask.toAndroid(),
            0.5f,
            name
        )
    }

    override fun prepareForListeningWithDecodingGraphWithName(
        name: String,
        computeGop: Boolean,
        callback: (Result<Boolean>) -> Unit
    ) = launchPigeon(callback, Dispatchers.IO) {
        recognizer.prepareForListeningWithDecodingGraphWithName(name, computeGop)
    }

    override fun startListening(callback: (Result<Boolean>) -> Unit) =
        launchPigeon(callback, Dispatchers.IO) { recognizer.startListening() }

    override fun stopListening(callback: (Result<Boolean>) -> Unit) =
        launchPigeon(callback, Dispatchers.IO) { recognizer.stopListening() }
}

private fun NativeSpeakingTask.toAndroid() = when (this) {
    NativeSpeakingTask.DEFAULT_TASK -> KASRSpeakingTask.KASRSpeakingTaskDefault
    NativeSpeakingTask.ORAL_READING -> KASRSpeakingTask.KASRSpeakingTaskOralReading
}

private fun KASRResult.toDart(isFinal: Boolean) = NativeASREvent(text, words.map { it.toDart() }, isFinal)

private fun KASRWord.toDart() = NativeASRWord(text, phones.map { it.toDart() })

private fun KASRPhone.toDart() = NativeASRPhone(text, pronunciationScore.toDouble())
