//
//  Beacon.swift
//  WiTracingAR
//
//  Created by x on 25/11/2022.
//

import Foundation
import CoreLocation

struct RSSIMeasurement {
    let rssi:Int
    let timestamp:Double
}

extension Array where Element == RSSIMeasurement {
    func min() -> RSSIMeasurement? {
        if self.count <= 0 {
            return nil
        }
        let sorted = self.sorted { lhs, rhs in
            return lhs.rssi > rhs.rssi
        }
        return sorted.last!
    }
    
    func max() -> RSSIMeasurement? {
        if self.count <= 0 {
            return nil
        }
        let sorted = self.sorted { lhs, rhs in
            return lhs.rssi < rhs.rssi
        }
        return sorted.last!
    }
    
    func avg() -> RSSIMeasurement? {
        if self.count <= 0 {
            return nil
        }
        var rssi:Int = 0
        var timestamp:Double = 0.0
        for measurement in self {
            rssi += measurement.rssi
            timestamp += measurement.timestamp
        }
        rssi /= self.count
        timestamp /= Double(self.count)
        return RSSIMeasurement(rssi: rssi, timestamp: timestamp)
    }
}

class Beacon: ObservableObject, Identifiable {
    static let maxRssi:Int = -25
    static let minRssi:Int = -100
    static let maxRssisLen:Int = 50
    static let detectableTimeWindow:Double = 3
    //MARK: - Beacon Properties
    var id:String {return String(format: "%@:%d:%d", String(uuid.suffix(8)), major, minor)}
    var coordinate: Coordinate = Coordinate()
    var uuid:String
    var major:Int
    var minor:Int
    @Published var rssi:Int = Beacon.minRssi
    var rssis:[RSSIMeasurement] = []
    var _proximity:CLProximity = CLProximity.unknown
    var proximity:String {
        switch self._proximity {
        case .immediate:
            return "immediate"
        case .near:
            return "near"
        case .far:
            return "far"
        case .unknown:
            return "unknown"
        @unknown default:
            return "unknown"
        }
    }
    var distance:Double {
        if self.isDetectable {
            return Signal.rssiToDistance(rssi: self.rssi)
        }
        else
        {
            return Double.infinity
        }
    }
    var isDetectable:Bool {
        return self.rssi > Beacon.minRssi && Date().timeIntervalSince1970 - self.coordinate.t < Beacon.detectableTimeWindow
    }
    static let speedTimeWindow:Double = 10 /// seconds
    var speed:Double {
        if self.rssis.count == 0 {
            return 0.0
        }
        let now = Date().timeIntervalSince1970
        let _rssis = self.rssis.filter { now - $0.timestamp < Beacon.speedTimeWindow}
        return Double(_rssis.count) / Beacon.speedTimeWindow
    }

    //MARK: - Beacon Constructor
    init(uuid: String, major: Int, minor: Int) {
        self.uuid = uuid
        self.major = major
        self.minor = minor
    }
    
    convenience init(uuid: String, major: Int, minor: Int, rssi: Int, coordinate:Coordinate) {
        self.init(uuid: uuid, major: major, minor: minor)
        self.coordinate = coordinate
    }
    
    convenience init(clBeacon: CLBeacon) {
        self.init(uuid: clBeacon.uuid.uuidString, major: Int(truncating: clBeacon.major), minor: Int(truncating: clBeacon.minor))
        self.rssi = clBeacon.rssi
        self._proximity = clBeacon.proximity
        self.coordinate.t = clBeacon.timestamp.timeIntervalSince1970
        self.rssis.append(RSSIMeasurement(rssi: rssi, timestamp: self.coordinate.t))
    }
    
    //MARK: - Beacon Methods
    func update(rssi:Int, timestamp: Double) {
        self.rssi = rssi
        self.coordinate.t = timestamp
        self._proximity = CLProximity.unknown
        self.updateRssis(rssi: rssi, timestamp: timestamp)
    }
    
    func update(clBeacon: CLBeacon) {
        let timestamp = clBeacon.timestamp.timeIntervalSince1970
        self.rssi = clBeacon.rssi
        self.coordinate.t = timestamp
        self._proximity = clBeacon.proximity
        self.updateRssis(rssi: rssi, timestamp: timestamp)
    }
    
    func updateRssis(rssi:Int, timestamp:Double) {
        self.rssis.append(RSSIMeasurement(rssi: rssi, timestamp: timestamp))
        if self.rssis.count > Beacon.maxRssisLen {
            self.rssis.removeFirst()
        }
    }
}

extension Beacon : CustomStringConvertible {
    var description: String {
        return String(format:"%@ | %@ | %d dBm | %@", self.id, self.coordinate.description, self.rssi, self.proximity)
    }
}

extension Array where Element == Beacon {
    func sortByRSSI() -> [Beacon] {
        return self.sorted { lhs, rhs in
            return lhs.rssi > rhs.rssi
        }
    }
}

extension Dictionary where Key == String, Value == Beacon {
    func sortByRSSI() -> [Beacon] {
        return Array(self.values).sortByRSSI()
    }
}


extension CLBeacon {
    func toBeacon() -> Beacon {
        return Beacon(clBeacon: self)
    }
}
