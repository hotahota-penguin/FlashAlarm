import AVFoundation
import AudioToolbox

@Observable
class AudioManager {
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    func playAlarmSound(_ soundName: String) {
        // For iOS system sounds, we'll use AudioServicesPlaySystemSound
        // This is a simple approach that works without audio files
        let sound = AlarmSound(rawValue: soundName) ?? .default
        
        // Play system sound repeatedly
        AudioServicesPlaySystemSound(sound.systemSoundID)
        isPlaying = true
        
        // Schedule repeated playback
        scheduleNextSound(sound.systemSoundID)
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
