import Foundation
import Combine

@Observable
class AlarmStorage {
    private let storageKey = "SavedAlarms"
    var alarms: [Alarm] = []
    private let scheduler = AlarmScheduler.shared
    private var settings: UserSettings?
    
    init(settings: UserSettings? = nil) {
        self.settings = settings
        loadAlarms()
    }
    
    func loadAlarms() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Alarm].self, from: data) {
            alarms = decoded
            // Reschedule all enabled alarms
            let snoozeInterval = settings?.snoozeInterval ?? 2
            for alarm in alarms where alarm.isEnabled {
                scheduler.scheduleNotification(for: alarm, snoozeInterval: snoozeInterval)
            }
        }
    }
    
    func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        saveAlarms()
        if alarm.isEnabled {
            let snoozeInterval = settings?.snoozeInterval ?? 2
            scheduler.scheduleNotification(for: alarm, snoozeInterval: snoozeInterval)
        }
    }
    
    func updateAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
            saveAlarms()
            
            // Cancel old notification and schedule new one if enabled
            scheduler.cancelNotification(for: alarm)
            if alarm.isEnabled {
                let snoozeInterval = settings?.snoozeInterval ?? 2
                scheduler.scheduleNotification(for: alarm, snoozeInterval: snoozeInterval)
            }
        }
    }
    
    func deleteAlarm(_ alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()
        scheduler.cancelNotification(for: alarm)
    }
}
