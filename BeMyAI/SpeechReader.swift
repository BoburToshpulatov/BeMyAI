// SpeechReader.swift
import Foundation
import AVFoundation
import Combine

/// A simple speech helper that can be observed from SwiftUI.
/// Matches the API used in BeMyAI.swift: `speak(text:)` and `stop()`.
final class SpeechReader: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    /// Optional published state if you want to bind to UI later.
    @Published var isSpeaking: Bool = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Speak the provided text from the beginning.
    /// Calls stop() first to ensure we restart from the start.
    func speak(text: String) {
        stop() // ensure fresh start
        guard !text.isEmpty else { return }

        let utterance = AVSpeechUtterance(string: text)
        // Tweak voice, rate, pitch to taste:
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.languageCode ?? "en-US")
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0

        synthesizer.speak(utterance)
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = true
        }
    }

    /// Immediately stop speaking.
    func stop() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension SpeechReader: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
        }
    }
}
