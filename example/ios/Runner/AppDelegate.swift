import UIKit
import Flutter
import flutter_background_executor

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      SwiftFlutterBackgroundExecutorPlugin.setPluginRegistrantCallback { registry in
          // Registry in this case is the FlutterEngine that is created in Workmanager's
          // performFetchWithCompletionHandler or BGAppRefreshTask.
          // This will make other plugins available during a background operation.
          GeneratedPluginRegistrant.register(with: registry)
      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
