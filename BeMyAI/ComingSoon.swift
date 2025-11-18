import SwiftUI

struct ComingSoonView: View {
    @State private var animate = false
    @State private var float = false

    var body: some View {
        ZStack {
            // MARK: - Background gradient
            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.45),
                    Color.purple.opacity(0.35),
                    Color.blue.opacity(0.35)
                ],
                startPoint: animate ? .topLeading : .bottomTrailing,
                endPoint: animate ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .blur(radius: 28)
            .animation(.easeInOut(duration: 6).repeatForever(), value: animate)

            // MARK: - Floating blurred circles
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.35))
                    .frame(width: 160, height: 160)
                    .offset(x: float ? -120 : -80, y: float ? -150 : -90)
                    .blur(radius: 22)
                    .animation(.easeInOut(duration: 5).repeatForever(), value: float)

                Circle()
                    .fill(Color.purple.opacity(0.35))
                    .frame(width: 200, height: 200)
                    .offset(x: float ? 110 : 70, y: float ? 160 : 120)
                    .blur(radius: 26)
                    .animation(.easeInOut(duration: 5).repeatForever(), value: float)
            }

            // MARK: - Main card
            VStack(spacing: 22) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(maxWidth: .infinity)
                        .frame(height: 240)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 22, y: 12)

                    VStack(spacing: 16) {
                        Image(systemName: "hammer.circle.fill")
                            .font(.system(size: 64))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 8, y: 4)

                        Text("Coming Soon")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("This feature is still being crafted.\nWe’re building something amazing for you.")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                .padding(.horizontal, 22)
                .scaleEffect(animate ? 1.0 : 0.96)
                .animation(
                    .spring(response: 0.9, dampingFraction: 0.75, blendDuration: 0.4)
                        .repeatForever(autoreverses: true),
                    value: animate
                )

                // MARK: - Pill button
                Text("Stay tuned")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
                    )
                    .padding(.top, 12)
                    .scaleEffect(animate ? 1 : 0.97)
            }
        }
        .onAppear {
            animate = true
            float = true
        }
    }
}


