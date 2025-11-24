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
    
    init() {
        let savedMaxAttempts = UserDefaults.standard.integer(forKey: "maxAttempts")
        self.maxAttempts = savedMaxAttempts == 0 ? 3 : savedMaxAttempts
        
        let savedSnoozeInterval = UserDefaults.standard.integer(forKey: "snoozeInterval")
        self.snoozeInterval = savedSnoozeInterval == 0 ? 2 : savedSnoozeInterval
    }
}
