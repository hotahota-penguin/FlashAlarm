import SwiftUI

struct AlarmListView: View {
    @State private var settings = UserSettings()
    @State private var storage: AlarmStorage
    @State private var isShowingEditView = false
    @State private var editingAlarm: Alarm? = nil
    @State private var activeAlarm: Alarm? = nil
    @State private var isShowingSettings = false
    private let scheduler = AlarmScheduler.shared
    
    init() {
        let settings = UserSettings()
        _settings = State(initialValue: settings)
        _storage = State(initialValue: AlarmStorage(settings: settings))
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(storage.alarms) { alarm in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(alarm.time, style: .time)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text(alarm.label)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { alarm.isEnabled },
                            set: { newValue in
                                var updatedAlarm = alarm
                                updatedAlarm.isEnabled = newValue
                                storage.updateAlarm(updatedAlarm)
                            }
                        ))
                        .labelsHidden()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingAlarm = alarm
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            storage.deleteAlarm(alarm)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            activeAlarm = alarm
                        } label: {
                            Label("Test", systemImage: "play.fill")
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isShowingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        editingAlarm = nil
                        isShowingEditView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $editingAlarm) { alarm in
                AlarmEditView(alarm: alarm) { updatedAlarm in
                    storage.updateAlarm(updatedAlarm)
                }
            }
            .sheet(isPresented: $isShowingEditView) {
                AlarmEditView(alarm: nil) { newAlarm in
                    storage.addAlarm(newAlarm)
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(settings: settings)
            }
            .fullScreenCover(item: $activeAlarm) { alarm in
                FlashAnzanView(
                    settings: alarm.flashAnzanSettings,
                    soundName: alarm.soundName,
                    maxAttempts: settings.maxAttempts
                ) { success in
                    // Cancel repeat notifications when alarm is dismissed
                    scheduler.cancelNotification(for: alarm)
                    
                    // Disable the alarm after dismissal
                    var updatedAlarm = alarm
                    updatedAlarm.isEnabled = false
                    storage.updateAlarm(updatedAlarm)
                    
                    // Always dismiss, regardless of success or failure
                    activeAlarm = nil
                }
            }
            .task {
                // Request notification permissions on first launch
                _ = await scheduler.requestPermissions()
            }
            .onAppear {
                // Check if app was launched from notification (when app was terminated)
                if let alarmId = AppDelegate.shared?.activeAlarmId,
                   let alarm = storage.alarms.first(where: { $0.id.uuidString == alarmId }) {
                    activeAlarm = alarm
                    AppDelegate.shared?.activeAlarmId = nil
                } else {
                    // Check for any active alarms that should be triggered
                    checkForActiveAlarms()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TriggerAlarm"))) { notification in
                // Handle alarm trigger when app is in foreground
                if let alarmId = notification.userInfo?["alarmId"] as? String,
                   let alarm = storage.alarms.first(where: { $0.id.uuidString == alarmId }) {
                    activeAlarm = alarm
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Check if app was launched from notification (when app was in background)
                if let alarmId = AppDelegate.shared?.activeAlarmId,
                   let alarm = storage.alarms.first(where: { $0.id.uuidString == alarmId }) {
                    activeAlarm = alarm
                    AppDelegate.shared?.activeAlarmId = nil
                }
            }
        }
    }
    
    private func checkForActiveAlarms() {
        let calendar = Calendar.current
        let now = Date()
        
        // Check each enabled alarm
        for alarm in storage.alarms where alarm.isEnabled {
            let alarmComponents = calendar.dateComponents([.hour, .minute], from: alarm.time)
            
            // Get today's alarm time
            guard let todayAlarmTime = calendar.date(bySettingHour: alarmComponents.hour ?? 0,
                                                      minute: alarmComponents.minute ?? 0,
                                                      second: 0,
                                                      of: now) else { continue }
            
            // Calculate the end time (alarm time + snooze interval * max repeats)
            let maxRepeatTime = calendar.date(byAdding: .minute,
                                             value: settings.snoozeInterval * 10,
                                             to: todayAlarmTime) ?? todayAlarmTime
            
            // If current time is between alarm time and max repeat time, trigger alarm
            if now >= todayAlarmTime && now <= maxRepeatTime {
                activeAlarm = alarm
                break // Only trigger one alarm at a time
            }
        }
    }
}

#Preview {
    AlarmListView()
}
