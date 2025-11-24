import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static var shared: AppDelegate?
    var activeAlarmId: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.shared = self
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
        
        // Trigger alarm immediately when app is in foreground
        if let alarmId = notification.request.content.userInfo["alarmId"] as? String {
            activeAlarmId = alarmId
            // Post notification to trigger alarm in AlarmListView
            NotificationCenter.default.post(name: NSNotification.Name("TriggerAlarm"), object: nil, userInfo: ["alarmId": alarmId])
        }
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let alarmId = response.notification.request.content.userInfo["alarmId"] as? String {
            activeAlarmId = alarmId
        }
        completionHandler()
    }
}

@main
struct FlashAlarmApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
