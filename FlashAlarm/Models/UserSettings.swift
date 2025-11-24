import Foundation
import SwiftUI

@Observable
class UserSettings {
    var maxAttempts: Int {
        didSet {
            UserDefaults.standard.set(maxAttempts, forKey: "maxAttempts")
        }
    }
    
    var snoozeInterval: Int {
        didSet {
            UserDefaults.standard.set(snoozeInterval, forKey: "snoozeInterval")
        }
    }
    
    var showNotificationSoundAlert: Bool {
        didSet {
            UserDefaults.standard.set(showNotificationSoundAlert, forKey: "showNotificationSoundAlert")
        }
    }
    
    init() {
        let savedMaxAttempts = UserDefaults.standard.integer(forKey: "maxAttempts")
        self.maxAttempts = savedMaxAttempts == 0 ? 3 : savedMaxAttempts
        
        let savedSnoozeInterval = UserDefaults.standard.integer(forKey: "snoozeInterval")
        self.snoozeInterval = savedSnoozeInterval == 0 ? 2 : savedSnoozeInterval
        
        // Default to true (show alert) if not set
        if UserDefaults.standard.object(forKey: "showNotificationSoundAlert") == nil {
            self.showNotificationSoundAlert = true
        } else {
            self.showNotificationSoundAlert = UserDefaults.standard.bool(forKey: "showNotificationSoundAlert")
        }
    }
}
