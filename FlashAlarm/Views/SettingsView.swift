import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var settings: UserSettings
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Flash Anzan")) {
                    Stepper("Max Attempts: \(settings.maxAttempts)", value: $settings.maxAttempts, in: 1...10)
                    Text("アラームを止めるまでの最大試行回数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Alarm Repeat")) {
                    Stepper("Snooze Interval: \(settings.snoozeInterval) min", value: $settings.snoozeInterval, in: 1...10)
                    Text("アラームが繰り返される間隔（分）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(settings: UserSettings())
}
