import UIKit
import Flutter
import Firebase
import flutter_downloader

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
      }else{
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
      }
      application.registerForRemoteNotifications()
      
      GeneratedPluginRegistrant.register(with: self)
      FlutterDownloaderPlugin.setPluginRegistrantCallback { registry in
          if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
              FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
          }
      }
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

