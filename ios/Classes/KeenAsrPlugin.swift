import Flutter
import KeenASR
import UIKit

public class KeenAsrPlugin: NSObject, FlutterPlugin, NativeKeenASR,
    KIOSRecognizerDelegate
{
    var eventSink: PigeonEventSink<NativeASREvent>? = nil

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = KeenAsrPlugin()
        NativeKeenASRSetup.setUp(
            binaryMessenger: registrar.messenger(), api: instance)
        NativeStreamKeenASREventsStreamHandler.register(
            with: registrar.messenger(), streamHandler: StreamHandler(instance))
    }

    func initializeWithAsset(
        bundleName: String,
        completion: @escaping (Result<Bool, any Error>) -> Void
    ) {
        launch(for: completion) { [self] in
            let result = KIOSRecognizer.initWithASRBundle(bundleName)
            if result {
                recognizer().delegate = self
            }
            return result
        }
    }

    func createDecodingGraphFromPhrases(
        phrases: [String], speakingTask: NativeSpeakingTask, name: String,
        completion: @escaping (Result<Bool, any Error>) -> Void
    ) {
        launch(for: completion) {
            KIOSDecodingGraph.createDecodingGraph(
                fromPhrases: phrases, for: recognizer(),
                using: nil, andTask: speakingTask.toIos(), andSaveWithName: name
            )
        }
    }

    func prepareForListeningWithDecodingGraphWithName(
        name: String, computeGop: Bool,
        completion: @escaping (Result<Bool, any Error>) -> Void
    ) {
        launch(for: completion) {
            recognizer().prepareForListeningWithDecodingGraph(
                withName: name, withGoPComputation: computeGop)
        }
    }

    func startListening(completion: @escaping (Result<Bool, any Error>) -> Void)
    {
        launch(for: completion) { recognizer().startListening(nil) }
    }

    func stopListening(completion: @escaping (Result<Bool, any Error>) -> Void)
    {
        launch(for: completion) {
            recognizer().stopListening()
            return true
        }
    }

    private func launch(
        for completion: @escaping (Result<Bool, any Error>) -> Void,
        _ block: @escaping () -> Bool
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            completion(.success(block()))
        }
    }

    public func unwindAppAudioBeforeAudioInterrupt() {}

    public func recognizerPartialResult(
        _ result: KIOSResult, for recognizer: KIOSRecognizer
    ) {
        eventSink?.success(result.toDart(isFinal: false))
    }

    public func recognizerFinalResponse(
        _ response: KIOSResponse, for recognizer: KIOSRecognizer
    ) {
        eventSink?.success(response.result!.toDart(isFinal: true))
    }
}

private class StreamHandler: NativeStreamKeenASREventsStreamHandler {
    let plugin: KeenAsrPlugin

    init(_ plugin: KeenAsrPlugin) {
        self.plugin = plugin
    }

    override func onListen(
        withArguments arguments: Any?, sink: PigeonEventSink<NativeASREvent>
    ) {
        plugin.eventSink = sink
    }
}

private func recognizer() -> KIOSRecognizer {
    return KIOSRecognizer.sharedInstance()!
}

extension NativeSpeakingTask {
    func toIos() -> KIOSSpeakingTask {
        switch self {
        case .defaultTask: return .default
        case .oralReading: return .oralReading
        }
    }
}

extension KIOSResult {
    func toDart(isFinal: Bool) -> NativeASREvent {
        return NativeASREvent(
            text: text, words: words?.map { $0.toDart() } ?? [],
            isFinal: isFinal)
    }
}

extension KIOSWord {
    func toDart() -> NativeASRWord {
        return NativeASRWord(
            text: text, phones: phones?.map { $0.toDart() } ?? [])
    }
}

extension KIOSPhone {
    func toDart() -> NativeASRPhone {
        return NativeASRPhone(
            text: text, score: pronunciationScore?.doubleValue ?? 0)
    }
}
