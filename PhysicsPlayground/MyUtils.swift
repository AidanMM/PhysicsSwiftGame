//
//  MyUtils.swift
//  PhysicsPlayground
//
//  Created by jefferson on 4/6/16.
//  Copyright © 2016 tony. All rights reserved.
//

import UIKit
import CoreGraphics
import SpriteKit

func is4SorOlder()->Bool{
    let max_height = max(UIScreen.mainScreen().bounds.width,UIScreen.mainScreen().bounds.height)
    return max_height == 480
}

func textureWithLinearGradient(startPoint startPoint:CGPoint, endPoint:CGPoint, size:CGSize, colors:[CGColor])->SKTexture{
    // http://www.ioscreator.com/tutorials/draw-gradients-core-graphics-ios8-swift
    UIGraphicsBeginImageContext(size)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let ctx = UIGraphicsGetCurrentContext()
    let gradient = CGGradientCreateWithColors(colorSpace, colors, nil)
    
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, .DrawsBeforeStartLocation)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    let texture = SKTexture(image: image)
    texture.filteringMode = .Linear
    
    return texture
    
}

func vectorByRotatingVectorClockwise(v:CGVector)->CGVector{
    var newVector = CGVectorMake(0, 0)
    newVector.dx = v.dy
    newVector.dy = -v.dx
    return newVector
}

