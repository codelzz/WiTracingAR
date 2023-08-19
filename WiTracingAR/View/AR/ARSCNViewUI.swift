//
//  ARSCNViewSUI.swift
//  WiTracingAR
//
//  Created by x on 27/11/2022.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit

struct ARSCNViewContainer: UIViewRepresentable {
    @EnvironmentObject var arscnManager: ARSCNManager
    
    func makeUIView(context: Context) -> ARSCNView {
        return arscnManager.arscnView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
    }
}

struct ARSCNViewUI: View {
    @EnvironmentObject var arscnManager: ARSCNManager
    @AppStorage(Constant.AppStorageKey.IsAREnabled) private var isAREnabled = true
    @AppStorage(Constant.AppStorageKey.UdpHost) private var UdpHost:String = Constant.Network.DefaultUdpHost
    @AppStorage(Constant.AppStorageKey.UdpPort) private var UdpPort:Int = Constant.Network.DefaultUdpPort
    
    var body: some View {
        if isAREnabled {
            ARSCNViewContainer()
                .onAppear(perform: self.onAppear )
//                .onDisappear(perform: self.onDisappear) // comments to allow AR capturing in all time.
        } else {
            Text("AR is disable.")
                .foregroundColor(.secondary)
                .font(.title)
                .navigationTitle("AR")
        }
    }
    
    func onAppear() {
        arscnManager.run(host: self.UdpHost, port: self.UdpPort)
    }
    
    func onDisappear() {
        arscnManager.pause()
    }
}
