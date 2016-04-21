//
//  MotionManager.swift
//  PhysicsPlayground
//
//  Created by jefferson on 4/6/16.
//  Copyright © 2016 tony. All rights reserved.
//

import Foundation
import CoreMotion
import CoreGraphics

class MotionManager{
    static let sharedMotionManager = MotionManager() // single instance
    let manager = CMMotionManager()
    var rotation:CGFloat = 0
    var gravityVector = CGVectorMake(0, 0)
    var transform = CGAffineTransformMakeRotation(0)
    
        
    // This prevents others from using the default initializer for this class.
    private init() {}
    
    func startUpdates(){
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.1
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()){
                data, error in
                guard data != nil else {
                    print("There was an error: \(error)")
                    return
                }
        
                self.rotation = CGFloat(atan2(data!.gravity.x, data!.gravity.y) - M_PI)
                self.gravityVector = CGVectorMake(CGFloat(data!.gravity.x), CGFloat(data!.gravity.y)) * 9.8
                self.transform = CGAffineTransformMakeRotation(CGFloat(self.rotation))
            } // end block
        }
    }
    
    func stopUpdates(){
        if manager.deviceMotionAvailable {
            manager.stopDeviceMotionUpdates()
        }
    }
    
    
}

