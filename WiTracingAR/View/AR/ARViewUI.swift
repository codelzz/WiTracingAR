//
//  ARViewContainer.swift
//  WiTracingAR
//
//  Created by x on 25/11/2022.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var arManager: ARManager
    
    func makeUIView(context: Context) -> ARView {
        return arManager.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

struct ARViewUI: View {
    @EnvironmentObject var arManager: ARManager
    @AppStorage(Constant.AppStorageKey.IsAREnabled) private var isAREnabled = true
    @AppStorage(Constant.AppStorageKey.UdpHost) private var UdpHost:String = Constant.Network.DefaultUdpHost
    @AppStorage(Constant.AppStorageKey.UdpPort) private var UdpPort:Int = Constant.Network.DefaultUdpPort
    
    var body: some View {
        if isAREnabled {
            ARViewContainer()
                .onAppear(perform: self.onAppear )
                .onDisappear(perform: self.onDisappear)
        } else {
            Text("AR is disable.")
                .foregroundColor(.secondary)
                .font(.title)
                .navigationTitle("AR")
        }
    }
    
    func onAppear() {
        arManager.run(host: self.UdpHost, port: self.UdpPort)
    }
    
    func onDisappear() {
        arManager.pause()
    }
}
