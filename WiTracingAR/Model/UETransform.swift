//
//  UETransform.swift
//  WiTracingAR
//
//  Created by x on 25/11/2022.
//

import Foundation
import ARKit
import RealityKit

/// Transform fit Unreal Engine
struct UETransform: CustomStringConvertible, Codable {
    //MARK: - UETransform Properties
    let x:Float
    let y:Float
    let z:Float
    let roll:Float
    let pitch:Float
    let yaw:Float
    let rxname:[String]
    let rxrssi:[Int]
    
    //MARK: - UETransform Constructor
    init(x:Float, y:Float, z:Float, roll: Float, pitch: Float, yaw: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.roll = roll
        self.pitch = pitch
        self.yaw = yaw
        self.rxname = []
        self.rxrssi = []
    }
    
    init(frame:ARFrame, beacons:[String:Beacon]) {
        let position = UETransform.toUEPosition(position: frame.camera.transform.columns.3)
        self.x = position.x
        self.y = position.y
        self.z = position.z
        let eularAngles = UETransform.toUEEulerAngles(eulerAngles: frame.camera.eulerAngles)
        self.roll = eularAngles.x
        self.pitch = eularAngles.y
        self.yaw = eularAngles.z
        
        var names:[String] = []
        var rssis:[Int] = []
        for (name, beacon) in beacons {
            names.append(name)
            rssis.append(beacon.rssi)
        }
        self.rxname = names
        self.rxrssi = rssis
        
    }
    
    //MARK: - UETransform Methods
    var description: String {
        return String(format:"x=%.3f,y=%.3f,z=%.3f,roll=%.3f,pitch=%.3f,yaw=%.3f",
                      self.x, self.y, self.z, self.roll,self.pitch, self.yaw)
    }
    
    func toJSON() -> String? {
        do {
            let json = try JSONEncoder().encode(self)
            let jsonStr = String(data:json, encoding: .utf8)!
            return jsonStr
        }
        catch
        {
            print("[ERR] \(#function) \(error)")
        }
        return nil
    }
    
    //MARK: - UETransform Static Methods
    static func toUEPosition(position: simd_float4) -> simd_float3 {
        return simd_float3(-position.z * 100.0, position.x * 100.0, position.y * 100.0)
    }
    
    static func toUEEulerAngles(eulerAngles: simd_float3) -> simd_float3 {
        let factor:Float =  180 / Float.pi
        var roll = eulerAngles.z * factor
        roll = -roll-90.0
        if roll < -180 {
            roll += 360
        }
        if roll > 180 {
            roll -= 360
        }
        let pitch = eulerAngles.x * factor
        let yaw = -eulerAngles.y * factor
        return simd_float3(roll, pitch, yaw)
    }
    
    static func eulerAngleToRotation(eulerAngle: simd_float3) -> vector_float4 {
        /**
         Ref:  https://math.stackexchange.com/questions/2975109/how-to-convert-euler-angles-to-quaternions-and-get-the-same-euler-angles-back-fr
            EulerAngel => (Roll,Pitch,Yaw)
            1. Roll  (the z component) is the rotation about the node’s z-axis (in radians)
            2. Pitch (the x component) is the rotation about the node’s x-axis (in radians)
            3. Yaw   (the y component) is the rotation about the node’s y-axis (in radians)
         ```
             def euler_to_quaternion(r):
                 (yaw, pitch, roll) = (r[0], r[1], r[2])
                 qx = np.sin(roll/2) * np.cos(pitch/2) * np.cos(yaw/2) - np.cos(roll/2) * np.sin(pitch/2) * np.sin(yaw/2)
                 qy = np.cos(roll/2) * np.sin(pitch/2) * np.cos(yaw/2) + np.sin(roll/2) * np.cos(pitch/2) * np.sin(yaw/2)
                 qz = np.cos(roll/2) * np.cos(pitch/2) * np.sin(yaw/2) - np.sin(roll/2) * np.sin(pitch/2) * np.cos(yaw/2)
                 qw = np.cos(roll/2) * np.cos(pitch/2) * np.cos(yaw/2) + np.sin(roll/2) * np.sin(pitch/2) * np.sin(yaw/2)
                 return [qx, qy, qz, qw]
         ```
        */
        let roll      = eulerAngle.x
        let pitch     = eulerAngle.y
        let yaw       = eulerAngle.z
        let halfRoll  = roll * 0.5
        let halfPitch = pitch * 0.5
        let halfYaw   = yaw * 0.5
        let x = sinf(halfRoll) * cosf(halfPitch) * cosf(halfYaw) - cosf(halfRoll) * sinf(halfPitch) * sinf(halfYaw)
        let y = cosf(halfRoll) * sinf(halfPitch) * cosf(halfYaw) + sinf(halfRoll) * cosf(halfPitch) * sinf(halfYaw)
        let z = cosf(halfRoll) * cosf(halfPitch) * sinf(halfYaw) - sinf(halfRoll) * sinf(halfPitch) * cosf(halfYaw)
        let w = cosf(halfRoll) * cosf(halfPitch) * cosf(halfYaw) + sinf(halfRoll) * sinf(halfPitch) * sinf(halfYaw)
        return vector_float4(x,y,z,w)
    }
    
    static func rotationToEulerAngle(rotation: vector_float4) -> simd_float3 {
        /**
         ```
         def quaternion_to_euler(q):
             (x, y, z, w) = (q[0], q[1], q[2], q[3])
             t0 = +2.0 * (w * x + y * z)
             t1 = +1.0 - 2.0 * (x * x + y * y)
             roll = math.atan2(t0, t1)
             t2 = +2.0 * (w * y - z * x)
             t2 = +1.0 if t2 > +1.0 else t2
             t2 = -1.0 if t2 < -1.0 else t2
             pitch = math.asin(t2)
             t3 = +2.0 * (w * z + x * y)
             t4 = +1.0 - 2.0 * (y * y + z * z)
             yaw = math.atan2(t3, t4)
             return [roll, pitch, yaw]
         ```
         */
        
        let x = rotation.x
        let y = rotation.y
        let z = rotation.z
        let w = rotation.w
        let t0 = +2.0 * (w * x + y * z)
        let t1 = +1.0 - 2.0 * (x * x + y * y)
        let roll = atan2(t0, t1)
        var t2 = +2.0 * (w * y - z * x)
        if t2 > 1.0 {
            t2 = 1
        }
        if t2 < -1.0 {
            t2 = -1
        }
        let pitch = asin(t2)
        let t3 = +2.0 * (w * z + x * y)
        let t4 = +1.0 - 2.0 * (y * y + z * z)
        let yaw = atan2(t3, t4)
        return simd_float3(roll,pitch,yaw)
    }
}
