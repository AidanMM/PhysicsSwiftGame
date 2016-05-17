//
//  Portal.swift
//  PhysicsPlayground
//
//  Created by Aidan McInerny on 4/24/16.
//  Copyright © 2016 tony. All rights reserved.
//

import SpriteKit

class Portal:SKSpriteNode, SKPhysicsContactDelegate {
    var otherPortal:Portal?
    var primary:Bool = false
    
    func initialize(nodeToFit: SKSpriteNode) {
        self.setScale(1)
        self.zPosition = 1;
        self.name = "portal"
        self.size = nodeToFit.size
        self.position = nodeToFit.position
        //self.shader = SKShader(fileNamed: "WaterRipple.fsh")
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.size.width , height: self.size.height ))
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = 2
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.affectedByGravity = false
        
        self.hidden = false
    }
    
    func linkPortal(anotherPortal:Portal){
        otherPortal = anotherPortal
        otherPortal?.otherPortal = self
        self.colorBlendFactor = 1.0
        otherPortal?.colorBlendFactor = 1.0
        if otherPortal?.primary == false {
            self.color = SKColor.orangeColor()
            otherPortal?.color = SKColor.blueColor()
            primary = true
        } else {
            self.color = SKColor.blueColor()
            otherPortal?.color = SKColor.orangeColor()
            primary = false
        }
    }
    
    func unlink() {
        self.hidden = true
        self.color = SKColor.blackColor()
        self.otherPortal!.color = SKColor.blackColor()
        self.otherPortal?.hidden = true
        otherPortal?.otherPortal = nil
        otherPortal = nil
    }
    
    func cooldown() {
        
    }
    
    func telaportSprite(sprite:SKSpriteNode) {
        if otherPortal != nil {
            var dir = sprite.physicsBody?.velocity.normalized()
            dir = CGVectorMake(dir!.dx * (sprite.size.width - size.width), dir!.dy * (sprite.size.height - size.height))
            sprite.runAction(SKAction.moveTo(CGPoint(x: (otherPortal?.position.x)! + dir!.dx, y: (otherPortal?.position.y)! + dir!.dy), duration: 0))
            SKTAudio.sharedInstance().playSoundEffect("portal2.wav")
            unlink();
        }
    }
    
}
