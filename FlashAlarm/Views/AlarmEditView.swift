import SwiftUI

struct AlarmEditView: View {
    @Environment(\.dismiss) var dismiss
    var alarm: Alarm?
    var onSave: (Alarm) -> Void
    
    @State private var time: Date = Date()
    @State private var label: String = "Alarm"
    @State private var digitCount: Int = 1
    @State private var numberCount: Int = 5
    @State private var speed: Double = 1.0
    @State private var soundName: String = "default"
    @State private var repeatOnFailure: Bool = true
    
    init(alarm: Alarm? = nil, onSave: @escaping (Alarm) -> Void) {
        self.alarm = alarm
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
                        let settings = FlashAnzanSettings(digitCount: digitCount, numberCount: numberCount, speed: speed)
                        let newAlarm = Alarm(
                            id: alarm?.id ?? UUID(),
                            time: time,
                            label: label,
                            isEnabled: true,
                            flashAnzanSettings: settings,
                            soundName: soundName,
                            repeatOnFailure: repeatOnFailure
                        )
                        onSave(newAlarm)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AlarmEditView(onSave: { _ in })
}
