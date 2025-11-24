import Foundation

struct FlashAnzanSettings: Codable, Hashable {
    var digitCount: Int = 1
    var numberCount: Int = 5
    var speed: Double = 1.0 // Seconds per number
}

struct Alarm: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var time: Date
    var label: String
    var isEnabled: Bool
    var flashAnzanSettings: FlashAnzanSettings
    var soundName: String = "default"
    var repeatOnFailure: Bool = true
    
    init(id: UUID = UUID(), time: Date = Date(), label: String = "Alarm", isEnabled: Bool = true, flashAnzanSettings: FlashAnzanSettings = FlashAnzanSettings(), soundName: String = "default", repeatOnFailure: Bool = true) {
        self.id = id
        self.time = time
        self.label = label
        self.isEnabled = isEnabled
        self.flashAnzanSettings = flashAnzanSettings
        self.soundName = soundName
        self.repeatOnFailure = repeatOnFailure
    }
}
