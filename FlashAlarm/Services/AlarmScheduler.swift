import Foundation
import UserNotifications

@Observable
class AlarmScheduler {
    static let shared = AlarmScheduler()
    
    private init() {}
    
    // Request notification permissions
    func requestPermissions() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Error requesting notification permissions: \(error)")
            return false
        }
    }
    
    // Schedule notifications for an alarm (initial + repeats)
    func scheduleNotification(for alarm: Alarm, snoozeInterval: Int = 2) {
        guard alarm.isEnabled else { return }
        
        // Cancel any existing notifications first
        cancelNotification(for: alarm)
        
        let calendar = Calendar.current
        let alarmComponents = calendar.dateComponents([.hour, .minute], from: alarm.time)
        
        // Schedule initial notification + 10 repeats
        for i in 0..<10 {
            let content = UNMutableNotificationContent()
            content.title = "アラーム"
            content.body = alarm.label
            
            // Use the alarm's selected sound
            if let alarmSound = AlarmSound(rawValue: alarm.soundName.capitalized) {
                content.sound = alarmSound.notificationSound
            } else {
                content.sound = .default
            }
            
            content.categoryIdentifier = "ALARM_CATEGORY"
            content.userInfo = ["alarmId": alarm.id.uuidString]
            
            // Calculate trigger time for this repeat
            var triggerComponents = alarmComponents
            if i > 0 {
                // Add snooze interval for repeats
                if let alarmDate = calendar.date(from: alarmComponents),
                   let repeatDate = calendar.date(byAdding: .minute, value: i * snoozeInterval, to: alarmDate) {
                    triggerComponents = calendar.dateComponents([.hour, .minute], from: repeatDate)
                }
            }
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            
            let identifier = i == 0 ? alarm.id.uuidString : "\(alarm.id.uuidString)-repeat-\(i)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification \(identifier): \(error)")
                }
            }
        }
    }
    
    // Cancel all notifications for an alarm (including repeats)
    func cancelNotification(for alarm: Alarm) {
        var identifiers = [alarm.id.uuidString]
        // Add all repeat identifiers
        for i in 1..<10 {
            identifiers.append("\(alarm.id.uuidString)-repeat-\(i)")
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // Cancel all notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
