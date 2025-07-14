import Foundation
import Dependencies
import AVFoundation

enum SoundType {
    case start, pause, stop
}

protocol AudioPlayer {
    func playSound(_ type: SoundType)
}

struct SystemAudioPlayer: AudioPlayer {
    func playSound(_ type: SoundType) {
        let systemSoundID: SystemSoundID
        switch type {
        case .start: systemSoundID = 1113
        case .pause: systemSoundID = 1306
        case .stop: systemSoundID = 1057
        }
        AudioServicesPlaySystemSound(systemSoundID)
    }
}

extension DependencyValues {
    var audioPlayer: AudioPlayer {
        get { self[AudioPlayerKey.self] }
        set { self[AudioPlayerKey.self] = newValue }
    }
    
    private enum AudioPlayerKey: DependencyKey {
        static let liveValue: AudioPlayer = SystemAudioPlayer()
    }
}
