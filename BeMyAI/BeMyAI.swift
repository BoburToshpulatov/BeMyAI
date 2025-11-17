import SwiftUI
import AVFoundation

struct BeMyAI: View {
    @StateObject private var camera = CameraController()
    @StateObject private var speech = SpeechReader()

    @State private var showFlash = false
    @State private var aiText: String = ""
    @State private var loading = false
    @State private var isMuted = true   // default muted

    var body: some View {
        ZStack {
            CameraView(controller: camera)
                .edgesIgnoringSafeArea(.all)

            if showFlash {
                Color.white.opacity(0.85).edgesIgnoringSafeArea(.all)
            }

            
            VStack {
                HStack {
                    Spacer()
                    Button(action: toggleSpeech) {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 28))
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                }
                Spacer()
            }

            VStack {
                Spacer()

                // AI overlay
                if !aiText.isEmpty || loading {
                    VStack(spacing: 12) {
                        HStack {
                            Spacer()
                            Button(action: closeMessage) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white.opacity(0.8))
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
                        }
                        .frame(maxHeight: 250)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }

                // Take picture button
                HStack(spacing: 16) {
                    Button(action: takePicture) {
                        Text("Take picture")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 55)
                            .background(Color.accentColor)
                            .cornerRadius(14)
                    }

                    Button(action: { }) {
                        Text("History")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, minHeight: 55)
                            .background(.ultraThinMaterial)
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 25)
            }
        }
        .onAppear {
            camera.onPhotoCaptured = { img in
                Task { await analyze(img) }
            }
        }
    }



    func takePicture() {
        showFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { showFlash = false }
        camera.capture()
    }

    func analyze(_ image: UIImage) async {
        loading = true
        aiText = ""

        do {
            let result = try await AIService.shared.analyzeImage(image)
            aiText = result
            loading = false

          
            if !isMuted {
                speech.speak(text: result)
            }

        } catch {
            aiText = "Error: \(error.localizedDescription)"
            loading = false
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
