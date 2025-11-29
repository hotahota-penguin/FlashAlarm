import AVFoundation
import AudioToolbox

@Observable
class AudioManager {
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    func playAlarmSound(_ soundName: String) {
        // Get the sound file name from AlarmSound enum
        let sound = AlarmSound(rawValue: soundName) ?? .default
        let fileName = sound.fileName
        
        // Try to load the audio file
        if let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".caf", with: ""), withExtension: "caf") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("Error playing audio file: \(error)")
                // Fallback to system sound
                AudioServicesPlaySystemSound(sound.systemSoundID)
                isPlaying = true
                scheduleNextSound(sound.systemSoundID)
            }
        } else {
            // Fallback to system sound if file not found
            AudioServicesPlaySystemSound(sound.systemSoundID)
            isPlaying = true
            scheduleNextSound(sound.systemSoundID)
        }
    }
    
    private func scheduleNextSound(_ soundID: UInt32) {
        guard isPlaying else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            AudioServicesPlaySystemSound(soundID)
            self.scheduleNextSound(soundID)
        }
    }
    
    func stopAlarmSound() {
        isPlaying = false
        audioPlayer?.stop()
    }
}
