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
        // Map to iOS system notification sounds
        switch self {
        case .default: return .default
        case .chime: return UNNotificationSound(named: UNNotificationSoundName("Chime.caf"))
        case .bell: return UNNotificationSound(named: UNNotificationSoundName("Bell.caf"))
        case .radar: return UNNotificationSound(named: UNNotificationSoundName("Radar.caf"))
        case .alarm: return UNNotificationSound(named: UNNotificationSoundName("Alarm.caf"))
        }
    }
    
    var fileName: String? {
        // For custom sounds, return the filename
        // For now, we'll use system sounds
        return nil
    }
}
