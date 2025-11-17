//
//  CameraView 2.swift
//  BeMyAI
//
//  Created by Bobur Toshpulatov on 14/11/25.
//


import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    let controller: CameraController
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        // preview layer
        let layer = AVCaptureVideoPreviewLayer(session: controller.session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        
        // start camera
        controller.start()
        
        // update size when layout changes
        DispatchQueue.main.async {
            layer.frame = view.bounds
        }
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
