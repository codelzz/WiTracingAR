//
//  ARManager.swift
//  WiTracingAR
//
//  Created by x on 25/11/2022.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit

class ARManager: NSObject, ARSessionDelegate, ObservableObject {
    static var shared = ARManager()
    /// AR
    var arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
    var arConfig = ARWorldTrackingConfiguration()
    /// Networking
    let udpClient = UdpClient()
    let minUdpSendInterval = 0.05
    var prevUdpSendTime = Date().timeIntervalSince1970
    var hasResetTracking:Bool = false
    
    override init() {
        super.init()
        self.initAR()
    }
    
    func initAR() {
        /// https://developer.apple.com/documentation/arkit/arworldtrackingconfiguration
        self.arConfig.planeDetection = [.horizontal, .vertical]
        self.arConfig.environmentTexturing = .automatic
        self.arConfig.isAutoFocusEnabled = true
        if type(of: self.arConfig).supportsFrameSemantics(.sceneDepth) {
            self.arConfig.frameSemantics = .sceneDepth
        }
        self.arView.debugOptions = []
        self.arView.session.delegate = self
    }
    
    func run(host:String?, port:Int?) {
        /// connect udp network
        if let host = host, let port = port {
            self.udpClient.connect(host: host, port: port)
        }
        
        if !self.hasResetTracking {
            self.arView.session.run(self.arConfig, options: .resetTracking)
            self.hasResetTracking = true
        } else {
            self.arView.session.run(self.arConfig)
        }
    }
    
    func pause() {
        arView.session.pause()
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard Date().timeIntervalSince1970 - self.prevUdpSendTime > self.minUdpSendInterval else {
            return
        }
        /// https://developer.apple.com/documentation/arkit/arsessiondelegate
        let transform = UETransform(frame: frame, beacons: BeaconManager.shared.beacons)
//        print("[DBG] Transform:\(transform)")
        if let json = transform.toJSON() {
            self.udpClient.send(msg: json)
        }
        self.prevUdpSendTime = Date().timeIntervalSince1970
    }
    
}
