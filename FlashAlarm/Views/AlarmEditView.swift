import SwiftUI

struct AlarmEditView: View {
    @Environment(\.dismiss) var dismiss
    var alarm: Alarm?
    var onSave: (Alarm) -> Void
    var settings: UserSettings
    
    @State private var time: Date = Date()
    @State private var label: String = "Alarm"
    @State private var digitCount: Int = 1
    @State private var numberCount: Int = 5
    @State private var speed: Double = 1.0
    @State private var soundName: String = "default"
    @State private var repeatOnFailure: Bool = true
    @State private var showSoundAlert = false
    @State private var pendingAlarm: Alarm?
    
    init(alarm: Alarm? = nil, settings: UserSettings, onSave: @escaping (Alarm) -> Void) {
        self.alarm = alarm
        self.settings = settings
        self.onSave = onSave
        
        if let alarm = alarm {
            _time = State(initialValue: alarm.time)
            _label = State(initialValue: alarm.label)
            _digitCount = State(initialValue: alarm.flashAnzanSettings.digitCount)
            _numberCount = State(initialValue: alarm.flashAnzanSettings.numberCount)
            _speed = State(initialValue: alarm.flashAnzanSettings.speed)
            _soundName = State(initialValue: alarm.soundName)
            _repeatOnFailure = State(initialValue: alarm.repeatOnFailure)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Time")) {
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }
                
                Section(header: Text("Label")) {
                    TextField("Label", text: $label)
                }
                
                Section(header: Text("Alarm Sound")) {
                    Picker("Sound", selection: $soundName) {
                        ForEach(AlarmSound.allCases, id: \.rawValue) { sound in
                            Text(sound.rawValue).tag(sound.rawValue.lowercased())
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Flash Anzan Settings")) {
                    Stepper("Digits: \(digitCount)", value: $digitCount, in: 1...5)
                    Stepper("Numbers: \(numberCount)", value: $numberCount, in: 3...20)
                    VStack(alignment: .leading) {
                        Text("Speed: \(String(format: "%.1f", speed))s")
                        Slider(value: $speed, in: 0.1...3.0, step: 0.1) {
                            Text("Speed")
                        } minimumValueLabel: {
                            Image(systemName: "hare")
                        } maximumValueLabel: {
                            Image(systemName: "tortoise")
                        }
                    }
                    
                    Toggle("Repeat on Failure", isOn: $repeatOnFailure)
                }
            }
            .navigationTitle(alarm == nil ? "Add Alarm" : "Edit Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let alarmSettings = FlashAnzanSettings(digitCount: digitCount, numberCount: numberCount, speed: speed)
                        let newAlarm = Alarm(
                            id: alarm?.id ?? UUID(),
                            time: time,
                            label: label,
                            isEnabled: true,
                            flashAnzanSettings: alarmSettings,
                            soundName: soundName,
                            repeatOnFailure: repeatOnFailure
                        )
                        
                        if settings.showNotificationSoundAlert {
                            pendingAlarm = newAlarm
                            showSoundAlert = true
                        } else {
                            onSave(newAlarm)
                            dismiss()
                        }
                    }
                }
            }
            .alert("通知音について", isPresented: $showSoundAlert) {
                Button("OK", role: .cancel) {
                    if let alarm = pendingAlarm {
                        onSave(alarm)
                        dismiss()
                    }
                }
                Button("次回から表示しない") {
                    settings.showNotificationSoundAlert = false
                    if let alarm = pendingAlarm {
                        onSave(alarm)
                        dismiss()
                    }
                }
            } message: {
                Text("通知音は alarm.caf に固定されています。\nアプリ内でのアラーム音のみ選択した音が使用されます。")
            }
        }
    }
}

#Preview {
    AlarmEditView(settings: UserSettings(), onSave: { _ in })
}
