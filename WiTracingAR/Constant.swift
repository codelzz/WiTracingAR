//
//  Constant.swift
//  WiTracingAR
//
//  Created by x on 25/11/2022.
//

import Foundation

class Constant {
    /// About
    class About {
        static let Version:String = "0.0.1"
    }
    
    /// Network
    class Network {
        static let DefaultUdpHost:String = "192.168.31.110" // Win10 PC
//        static let DefaultUdpHost:String = "192.168.31.100" // MacOS
        static let DefaultUdpPort:Int = 9000
    }
    
    //MARK: - Beacon
    class Beacon {
        static let DefaultBeaconUUID = "35828EE5-8390-43AE-8457-C4C6BBC1B255"
    }
    
    //MARK: - AR / ARScene
    class ARSCN {
        static let DefaultSceneName = "art.scnassets/default.scn"
    }
    
    //MARK: - AppStorage Key
    class AppStorageKey {
        static let IsUdpEnabled:String = "IsUdpEnabled"
        static let IsAREnabled:String = "IsAREnabled"
        static let IsBeaconScanEnabled:String = "IsBeaconScanEnabled"
        static let BeaconUUID:String = "BeaconUUID"
        static let UdpHost:String = "UdpHost"
        static let UdpPort:String = "UdpPort"
    }
}
