import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    // Register the parent's "Around" live-audio channel against the
    // FlutterViewController's engine. In scene-based iOS apps,
    // FlutterImplicitEngineDelegate.didInitializeImplicitFlutterEngine
    // on AppDelegate doesn't always fire (or fires before the engine
    // we end up using), so the Dart side hits MissingPluginException
    // when it calls `kid_security/live_audio_player`. Doing it here
    // guarantees the channel is wired before the user can navigate to
    // the Around screen.
    if
      let appDelegate = UIApplication.shared.delegate as? AppDelegate,
      let windowScene = scene as? UIWindowScene,
      let rootVC = windowScene.windows.first?.rootViewController
        ?? window?.rootViewController,
      let flutterVC = findFlutterViewController(in: rootVC)
    {
      appDelegate.registerLiveAudioChannel(on: flutterVC.binaryMessenger)
    }
  }

  private func findFlutterViewController(in vc: UIViewController) -> FlutterViewController? {
    if let flutterVC = vc as? FlutterViewController { return flutterVC }
    for child in vc.children {
      if let found = findFlutterViewController(in: child) { return found }
    }
    if let presented = vc.presentedViewController {
      return findFlutterViewController(in: presented)
    }
    return nil
  }
}
