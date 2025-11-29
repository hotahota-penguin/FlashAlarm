import Foundation
import UserNotifications

enum AlarmSound: String, CaseIterable, Codable {
    case `default` = "Default"
    
    var systemSoundID: UInt32 {
        return 1005 // Fallback system sound
    }
    
    var notificationSound: UNNotificationSound {
        // Use mixkit-spaceship-alarm-998.caf for all notification sounds
        return UNNotificationSound(named: UNNotificationSoundName("mixkit-spaceship-alarm-998.caf"))
    }
    
    var fileName: String {
        return "mixkit-spaceship-alarm-998.caf"
    }
}
