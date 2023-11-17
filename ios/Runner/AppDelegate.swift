import UIKit
import Flutter
import flutter_downloader

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        GeneratedPluginRegistrant.register(with: self)
        FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    @objc func step(displaylink: CADisplayLink) {
        // Will be called once a frame has been built while matching desired frame rate
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        addBlurEffect()
    }

//    override func applicationWillResignActive(_ application: UIApplication) {
//        print("applicationWillResignActive")
//        addBlurEffect()
//    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        SecurityBlurEffect.removeBlurEffect()
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        SecurityBlurEffect.removeBlurEffect()
    }

    func addBlurEffect() {
        let BLURRED_IN_RECENT_TASK = "flutter.blurredInRecentTasks"

        let isBlurredInRecentTasks = UserDefaults.standard.bool(forKey: BLURRED_IN_RECENT_TASK)

        print("isBlurredInRecentTasks :", isBlurredInRecentTasks)
        if isBlurredInRecentTasks {
            SecurityBlurEffect.addBlurEffect()
        }
    }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}


