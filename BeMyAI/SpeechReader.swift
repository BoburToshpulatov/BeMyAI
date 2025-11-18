//
//  SpeechReader.swift
//  BeMyAI
//

import Foundation
import AVFoundation
import Combine

// -------------------------------
// SpeechReader implementation
// -------------------------------
final class SpeechReader: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    @Published var isSpeaking: Bool = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Always stops any current speech and begins speaking the provided text from the start.
    func speak(text: String) {
        // Ensure audio session is configured for playback and speaker output
        configureAudioSession()

        // stop any current speech to avoid overlapping
        stop()

        guard !text.isEmpty else { return }

        let utterance = AVSpeechUtterance(string: text)
        // Use the device language if available; fallback to en-US
        let lang = Locale.current.language.languageCode?.identifier ?? "en-US"
        utterance.voice = AVSpeechSynthesisVoice(language: lang)
        utterance.rate = 0.52
        utterance.pitchMultiplier = 1.0
        utterance.preUtteranceDelay = 0.02

        synthesizer.speak(utterance)
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = true
        }
    }

    /// Immediately stops speaking.
    func stop() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
        }
    }

    /// Configure AVAudioSession to use device speaker by default
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup error: \(error)")
        }
    }
}

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
