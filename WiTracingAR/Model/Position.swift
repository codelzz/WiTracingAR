//
//  Position.swift
//  WiTracingAR
//
//  Created by x on 24/11/2022.
//

import Foundation
import ARKit

struct Position: CustomStringConvertible {
    let x:Double
    let y:Double
    let z:Double
    
    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    var description: String {
        return String(format:"x=%.3f,y=%.3f,z=%.3f", self.x,self.y, self.z)
    }
}
