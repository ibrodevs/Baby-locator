import Flutter
import UIKit
import Firebase
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let liveAudioChannelName = "kid_security/live_audio_player"
  private var liveAudioEngine: AVAudioEngine?
  private var liveAudioPlayerNode: AVAudioPlayerNode?
  private var liveAudioFormat: AVAudioFormat?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    configureAudioSession()
    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    configureLiveAudioChannel(binaryMessenger: engineBridge.applicationRegistrar.messenger())
  }

  private func configureAudioSession() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(
        .playAndRecord,
        mode: .voiceChat,
        options: [.allowBluetooth, .defaultToSpeaker, .mixWithOthers]
      )
      try session.setActive(true)
    } catch {
      print("Audio session configuration error: \(error)")
    }
  }

  rivate func configureLiveAudioChannel(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: liveAudioChannelName, binaryMessenger: binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterError(code: "deallocated", message: nil, details: nil))
        return
      }

      switch call.method {
      case "initialize":
        guard
          let args = call.arguments as? [String: Any],
          let sampleRate = args["sampleRate"] as? Int,
          let channels = args["channels"] as? Int
        else {
          result(FlutterError(code: "bad_args", message: "Missing sampleRate/channels", details: nil))
          return
        }
        self.initializeLiveAudio(sampleRate: sampleRate, channels: channels)
        result(nil)
      case "start":
        self.liveAudioPlayerNode?.play()
        result(nil)
      case "appendPcm":
        guard
          let args = call.arguments as? [String: Any],
          let bytes = args["bytes"] as? FlutterStandardTypedData
        else {
          result(FlutterError(code: "bad_args", message: "Missing PCM bytes", details: nil))
          return
        }
        do {
          try self.appendLiveAudio(bytes: bytes.data)
          result(nil)
        } catch {
          result(FlutterError(code: "append_failed", message: error.localizedDescription, details: nil))
        }
      case "stop":
        self.liveAudioPlayerNode?.stop()
        self.liveAudioEngine?.stop()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func initializeLiveAudio(sampleRate: Int, channels: Int) {
    let engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    let format = AVAudioFormat(
      commonFormat: .pcmFormatInt16,
      sampleRate: Double(sampleRate),
      channels: AVAudioChannelCount(max(channels, 1)),
      interleaved: true
    )

    guard let format else { return }

    engine.attach(player)
    engine.connect(player, to: engine.mainMixerNode, format: format)

    do {
      try AVAudioSession.sharedInstance().setCategory(
        .playback,
        mode: .default,
        options: [.allowBluetooth, .defaultToSpeaker]
      )
      try AVAudioSession.sharedInstance().setActive(true)
      try engine.start()
    } catch {
      print("Live audio engine start error: \(error)")
    }

    liveAudioEngine = engine
    liveAudioPlayerNode = player
    liveAudioFormat = format
  }

  private func appendLiveAudio(bytes: Data) throws {
    guard
      let player = liveAudioPlayerNode,
      let format = liveAudioFormat
    else {
      throw NSError(domain: "LiveAudio", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Player is not initialized."
      ])
    }

    let bytesPerFrame = Int(format.streamDescription.pointee.mBytesPerFrame)
    if bytesPerFrame <= 0 {
      throw NSError(domain: "LiveAudio", code: 2, userInfo: [
        NSLocalizedDescriptionKey: "Invalid audio format."
      ])
    }
    let frameCapacity = AVAudioFrameCount(bytes.count / bytesPerFrame)
    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else {
      throw NSError(domain: "LiveAudio", code: 3, userInfo: [
        NSLocalizedDescriptionKey: "Unable to allocate audio buffer."
      ])
    }

    buffer.frameLength = frameCapacity
    bytes.withUnsafeBytes { rawBuffer in
      guard let source = rawBuffer.baseAddress else { return }
      memcpy(buffer.int16ChannelData![0], source, bytes.count)
    }
    player.scheduleBuffer(buffer, completionHandler: nil)
    if !player.isPlaying {
      player.play()
    }
  }
}
