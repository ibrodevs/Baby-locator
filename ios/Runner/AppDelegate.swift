import Flutter
import UIKit
import FirebaseCore
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  static let liveAudioChannelName = "kid_security/live_audio_player"
  private var liveAudioEngine: AVAudioEngine?
  private var liveAudioPlayerNode: AVAudioPlayerNode?
  private var liveAudioFormat: AVAudioFormat?
  private var registeredMessengers: [ObjectIdentifier: FlutterMethodChannel] = [:]

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
    registerLiveAudioChannel(on: engineBridge.applicationRegistrar.messenger())
  }

  /// Public so SceneDelegate can register the channel against the
  /// FlutterViewController's engine. Scene-based iOS apps don't always
  /// route `didInitializeImplicitFlutterEngine` to the AppDelegate, so
  /// without this the parent's "Around" feature throws
  /// MissingPluginException on real devices.
  func registerLiveAudioChannel(on messenger: FlutterBinaryMessenger) {
    let key = ObjectIdentifier(messenger as AnyObject)
    if registeredMessengers[key] != nil { return }
    let channel = FlutterMethodChannel(
      name: AppDelegate.liveAudioChannelName,
      binaryMessenger: messenger
    )
    attachLiveAudioHandler(to: channel)
    registeredMessengers[key] = channel
  }

  private func configureAudioSession() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(
        .playAndRecord,
        mode: .default,
        options: [.allowBluetooth, .defaultToSpeaker, .mixWithOthers]
      )
      try session.setActive(true)
    } catch {
      print("Audio session configuration error: \(error)")
    }
  }

  private func attachLiveAudioHandler(to channel: FlutterMethodChannel) {
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

    // Don't reconfigure the AVAudioSession category here. The original
    // code called setCategory(.playback, options: [.allowBluetooth,
    // .defaultToSpeaker]) — those options are only valid for
    // .playAndRecord and throw `OSStatus -50` on a real iPhone. The
    // throw aborts the whole `do` block before engine.start() runs, so
    // the audio engine never starts and the parent hears silence. The
    // simulator is more permissive, which is why "around" worked there
    // but not on a phone. The session was already configured in
    // configureAudioSession() at launch with a compatible combination.
    do {
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
