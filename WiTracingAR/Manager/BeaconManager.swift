//
//  BeaconManager.swift
//  WiTracingAR
//
//  Created by x on 25/11/2022.
//
/// Ref:
/// WWDC2019 what's new in CoreLocation https://developer.apple.com/videos/play/wwdc2019/705/
///
/// Region Monitoring to initiate rangine
/// Regine Monitoring no longer requires Always Authorization
///
/// Class:
/// CLBeaconRegion:CLRegion => uuid major minor (major/minor can be omi)
/// CLBeaconIdentityConstraint => uuid major minor
/// CLBeacon => uuid major minor
///
/// Beacon Workflow:
/// When in Use -> Monitor for BeaconRegion
/// - [Enter Region] -> Start Ranging -> BeaconFound -> [Status Update]
/// - [Exit Region] -> Stop Ranging

import Foundation
import CoreLocation

class BeaconManager : NSObject, ObservableObject {
    //MARK: - BeaconManager Properties
    static var shared = BeaconManager()
    var locationManager:CLLocationManager = CLLocationManager()
    @Published var beacons:[String:Beacon] = [:]
    var beaconRegion:CLBeaconRegion?
    var timer:Timer?
    var isScanEnable:Bool = false

    //MARK: - BeaconManager Constructor
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    //MARK: - BeaconManager Time Handler
    @objc func timerHandler() {
        for beacon in Array(self.beacons.values) {
            if !beacon.isDetectable {
                beacon.rssi = Beacon.minRssi
            }
        }
    }
    
    func run(uuid:String) {
        self.isScanEnable = true
        if let uuid = UUID(uuidString: uuid) {
            let constraint = CLBeaconIdentityConstraint(uuid: uuid)
            self.beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuid.uuidString)
            self.locationManager.startMonitoring(for: beaconRegion!)
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.timerHandler), userInfo: nil, repeats: true)
        }
    }
    
    func pause() {
        if let _ = self.beaconRegion {
            self.locationManager.stopMonitoring(for: self.beaconRegion!)
        }
        self.timer?.invalidate()
    }
}

extension BeaconManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion)
    {
        let beaconRegion = region as? CLBeaconRegion
        if state == .inside {
            /// Start ranging when inside a region
            manager.startRangingBeacons(satisfying: beaconRegion!.beaconIdentityConstraint)
        } else {
            /// Stop ranging when not inside a region
            manager.stopRangingBeacons(satisfying: beaconRegion!.beaconIdentityConstraint)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange clBeacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        for range in [CLProximity.immediate, .near, .far] {
            let proximityCLBeacons = clBeacons.filter { $0.proximity == range }
            for clBeacon in proximityCLBeacons {
                let beacon = Beacon(clBeacon: clBeacon)
                if beacons[beacon.id] == nil {
                    beacons[beacon.id] = beacon
                } else {
                    beacons[beacon.id]!.update(clBeacon: clBeacon)
                }
            }
        }
        
    }
}
