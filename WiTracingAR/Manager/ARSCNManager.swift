//
//  ARSCNManager.swift
//  WiTracingAR
//
//  Created by x on 27/11/2022.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit
import SceneKit

class ARSCNManager: NSObject, ARSCNViewDelegate, ARSessionDelegate, ObservableObject {
    static var shared = ARSCNManager()
    /// AR Scene
    var arscnView = ARSCNView(frame: .zero)
    var arscnConf = ARWorldTrackingConfiguration()

    /// Networking
    let udpClient = UdpClient()
    let minUdpSendInterval = 0.05
    var prevUdpSendTime = Date().timeIntervalSince1970
    
    /// Plane
    var didAddPlane:Bool = false
    
    override init() {
        super.init()
        self.initARSCN()
    }
    
    func initARSCN() {
        /// session
        self.arscnView.session.delegate = self
        /// view
        self.arscnView.delegate = self
        self.arscnView.showsStatistics = true
//        self.arscnView.scene = SCNScene(named: Constant.ARSCN.DefaultSceneName)!
    }
    
    func run(host:String?, port:Int?) {
        /// connect udp network
        if let host = host, let port = port {
            self.udpClient.connect(host: host, port: port)
        }
        /// configuration
        self.arscnConf.planeDetection = [.horizontal, .vertical]
        self.arscnView.session.run(self.arscnConf)
        
    }
    
    func pause() {
        self.arscnView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        /// https://developer.apple.com/documentation/arkit/arscnviewdelegate/2865794-renderer
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//        if !self.didAddPlane {
//            let width = CGFloat(planeAnchor.planeExtent.width)
//            let height = CGFloat(planeAnchor.planeExtent.height)
//            let plane = SCNPlane(width: width, height: height)
//            plane.materials.first?.diffuse.contents = UIColor.green.withAlphaComponent(0.5)
//            let planeNode = SCNNode(geometry: plane)
//
//            let x = planeAnchor.center.x
//            let y = planeAnchor.center.y
//            let z = planeAnchor.center.z
//
//            planeNode.position = SCNVector3(x: x, y: y, z: z)
//            planeNode.eulerAngles.x = -.pi / 2.0
//            node.addChildNode(planeNode)
//            self.didAddPlane = true
//        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? ARPlaneAnchor else {
//            return
//        }
//        let planeNode = node.childNodes.first
//        guard let plane = planeNode?.geometry as? SCNPlane else {
//            return
//        }
//
//        let width = CGFloat(planeAnchor.planeExtent.width)
//        let height = CGFloat(planeAnchor.planeExtent.height)
//        plane.width = width
//        plane.height = height
//
//        let x = planeAnchor.center.x
//        let y = planeAnchor.center.y
//        let z = planeAnchor.center.z
//        planeNode!.position = SCNVector3(x: x, y: y, z: z)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard Date().timeIntervalSince1970 - self.prevUdpSendTime > self.minUdpSendInterval else {
            return
        }
        /// https://developer.apple.com/documentation/arkit/arsessiondelegate
        if UserDefaults.standard.bool(forKey: Constant.AppStorageKey.IsUdpEnabled) {
            let transform = UETransform(frame: frame, beacons: BeaconManager.shared.beacons)
            if let json = transform.toJSON() {
                self.udpClient.send(msg: json)
            }
            self.prevUdpSendTime = Date().timeIntervalSince1970
        }

    }
}
