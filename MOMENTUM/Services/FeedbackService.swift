import AudioToolbox
import AVFoundation
import UIKit

final class FeedbackService {
    static let shared = FeedbackService()

    enum FeedbackEvent {
        case lightTap
        case shutter
        case filmAdvance
        case success
        case sliderTick
    }

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        lightImpact.prepare()
        softImpact.prepare()
        notification.prepare()
    }

    func play(_ event: FeedbackEvent) {
        switch event {
        case .lightTap:
            lightImpact.impactOccurred()
        case .shutter:
            lightImpact.impactOccurred(intensity: 0.9)
            playSystemSound(1108)
        case .filmAdvance:
            softImpact.impactOccurred()
            playSystemSound(1157)
        case .success:
            notification.notificationOccurred(.success)
            playSystemSound(1108)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                self.playSystemSound(1108)
            }
        case .sliderTick:
            lightImpact.impactOccurred(intensity: 0.35)
        }
    }

    private func playSystemSound(_ id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
}
