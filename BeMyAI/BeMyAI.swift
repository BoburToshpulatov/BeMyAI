//
//  BeMyAI 2.swift
//  BeMyAI
//
//  Created by Bobur Toshpulatov on 17/11/25.
//

import SwiftUI
import AVFoundation
import Combine

struct BeMyAI: View {
    @StateObject private var camera = CameraController()
    @StateObject private var speech = SpeechReader()

    @State private var showFlash = false
    @State private var aiText: String = ""
    @State private var loading = false

    // Default: unmuted -> start reading automatically when aiText is set.
    @State private var isMuted = false

    var body: some View {
        ZStack {
            CameraView(controller: camera)
                .edgesIgnoringSafeArea(.all)

            if showFlash {
                Color.white.opacity(0.85).edgesIgnoringSafeArea(.all)
            }

            // 🔊 Speaker button — stable position, fixed size, no movement
            VStack {
                HStack {
                    Spacer()
                    Button(action: toggleSpeech) {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.accentColor)
                            .frame(width: 60, height: 60) // FIXED → NO MOVEMENT
                            .background(
                                Circle().fill(Color.white)
                            )
                            .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 30)   // moved higher so it never goes behind text
                }
                Spacer()
            }
            .allowsHitTesting(true)

            VStack {
                Spacer()

                // AI overlay (floating card)
                if !aiText.isEmpty || loading {
                    VStack(spacing: 12) {
                        HStack {
                            Spacer()
                            Button(action: closeMessage) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }

                        if loading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        }

                        ScrollView {
                            Text(aiText)
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 2)
                        }
                        .frame(maxHeight: 260)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                    )
                    .padding(.horizontal, 18)
                }

                // 📸 Take Picture button — full width
                Button(action: takePicture) {
                    Text("Take picture")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 55)
                        .background(Color.accentColor)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            camera.onPhotoCaptured = { img in
                Task { await analyze(img) }
            }
        }
        .onChange(of: aiText) { newText in
            guard !newText.isEmpty else { return }
            if !isMuted {
                speech.speak(text: newText)
            }
        }
    }

    // MARK: - Functions

    func takePicture() {
        showFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { showFlash = false }
        camera.capture()
    }

    func analyze(_ image: UIImage) async {
        await MainActor.run {
            loading = true
            aiText = ""
        }

        do {
            let result = try await AIService.shared.analyzeImage(image)
            await MainActor.run {
                loading = false
                aiText = result
            }
        } catch {
            await MainActor.run {
                loading = false
                aiText = "Error: \(error.localizedDescription)"
            }
        }
    }

    func toggleSpeech() {
        isMuted.toggle()

        if isMuted {
            speech.stop()
        } else {
            if !aiText.isEmpty {
                speech.speak(text: aiText)
            }
        }
    }

    func closeMessage() {
        aiText = ""
        speech.stop()
    }
}
