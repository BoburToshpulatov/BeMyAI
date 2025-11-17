//
//  AIOverlayView.swift
//  BeMyAI
//
//  Created by Bobur Toshpulatov on 15/11/25.
//

import SwiftUI

struct AIOverlayView: View {
    let text: String
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("AI Description")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                
                ScrollView {
                    Text(text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .background(.ultraThinMaterial) // frosted glass effect
            .cornerRadius(20)
            .shadow(radius: 6)
            .padding(.horizontal, 20)
            .padding(.bottom, 60) // leave space for Take Picture button
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
