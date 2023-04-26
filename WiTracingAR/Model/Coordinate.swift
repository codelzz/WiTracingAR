//
//  Coordinate.swift
//  WiTracingAR
//
//  Created by x on 26/11/2022.
//

import Foundation
import Foundation
import ARKit

struct Coordinate {
    var x:Double
    var y:Double
    var z:Double
    var t:Double
    
    init(x: Double = 0, y: Double = 0, z: Double = 0, t: Double = Date().timeIntervalSince1970) {
        self.x = x
        self.y = y
        self.z = z
        self.t = t
    }
}

extension Coordinate : CustomStringConvertible {
    var description: String {
        return String(format:"x=%.2f,y=%.2f,z=%.2f,t=%.3f", self.x, self.y, self.z, self.t)
    }
}
