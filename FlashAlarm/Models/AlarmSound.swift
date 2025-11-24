import Foundation
import UserNotifications

enum AlarmSound: String, CaseIterable, Codable {
    case `default` = "Default"
    case chime = "Chime"
    case bell = "Bell"
    case radar = "Radar"
    case alarm = "Alarm"
    
    var systemSoundID: UInt32 {
        switch self {
        case .default: return 1005 // SMS Received
        case .chime: return 1013 // SMS Received 5
        case .bell: return 1013 // SMS Received 5
        case .radar: return 1013 // SMS Received 5
        case .alarm: return 1005 // SMS Received
        }
    }
    
    var notificationSound: UNNotificationSound {
        // Use alarm.caf for all notification sounds
        return UNNotificationSound(named: UNNotificationSoundName("alarm.caf"))
    }
    
    var fileName: String? {
        return "alarm.caf"
    }
}
