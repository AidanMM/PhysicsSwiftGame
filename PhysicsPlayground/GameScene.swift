
//
//  GameScene.swift
//  PhysicsPlayground
//
//  Created by jefferson on 3/1/16.
//  Copyright (c) 2016 tony. All rights reserved.
//
let PRINT_DEBUG_INFO = false
import SpriteKit
struct SpriteLayer {
    static let Background   : CGFloat = 0
    static let PlayableRect : CGFloat = 1
    static let HUD          : CGFloat = 2
    static let Sprite       : CGFloat = 3
    static let Message      : CGFloat = 4
}

struct PhysicsCategory {
    static let None:  UInt32 = 0
    static let Shape: UInt32 = 0b10
    static let Target:UInt32 = 0b100
    static let Objective:UInt32 = 0b10
}

class GameScene: SKScene,UIGestureRecognizerDelegate,SKPhysicsContactDelegate {
    var playableRect:CGRect = CGRectZero
    let square = SKSpriteNode(imageNamed: "square")
    
    let shrinkAction = SKAction.sequence([
        //SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false),
        SKAction.scaleTo(0.25, duration: 0.1),
        SKAction.removeFromParent()
        ])
    
    // MARK: - Initialization -
    override func didMoveToView(view: SKView) {
        // Calculate playable margin for landscape
        let maxAspectRatio: CGFloat = 16.0/9.0 // iPhone 5
        let maxAspectRatioHeight = size.width / maxAspectRatio
        let playableMargin: CGFloat = (size.height - maxAspectRatioHeight)/2
        playableRect = CGRect(x: 0, y: playableMargin,
            width: size.width, height: size.height-playableMargin*2)
        
        setupWorld()
    }
    
    // MARK: - Helpers -
    func setupWorld(){
        
        /*
        If we are on an iPad or a 4S, draw the playable rect.
        We will draw this as a procedurally generated texture - so we can see how it's done.
        */
        let deviceIdiom = UIScreen.mainScreen().traitCollection.userInterfaceIdiom
        if deviceIdiom == .Pad || is4SorOlder(){
            let color1 = UIColor(red: 48/255, green: 204/255, blue: 255/255, alpha: 0.3)
            let color2 = UIColor(red: 200/255, green: 251/255, blue: 255/255, alpha: 0.3)
            let texture = textureWithLinearGradient(
                startPoint: CGPointMake(0, 0),
                endPoint: CGPointMake(0, playableRect.height),
                size: playableRect.size,
                colors: [color1.CGColor,color2.CGColor])
            
            let bg = SKSpriteNode(texture: texture)
            bg.position = playableRect.origin
            bg.anchorPoint = CGPointMake(0, 0)
            bg.zPosition = SpriteLayer.PlayableRect
            
            addChild(bg)
        }
        
        
        // Physics
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
        square.physicsBody = SKPhysicsBody(rectangleOfSize: square.frame.size)
        
        //Set up physiscs things
        physicsWorld.contactDelegate = self;
            
    }
    
    // called by shaking the phone or Hardware > Shake Gesture in the simulator 
    func shake() {
        
    }
    
 
    override func update(currentTime: CFTimeInterval) {
        let mm = MotionManager.sharedMotionManager
        
         // make sure we're not on the simulator
        guard mm.gravityVector != CGVectorMake(0, 0) else{
            return
        }
        
        var grav = mm.gravityVector.normalized()
        if abs(grav.dx) > abs(grav.dy) {
            grav.dy = 0
        } else if abs(grav.dy) > abs(grav.dx) {
            grav.dx = 0
        }
        grav.normalize()
        grav *= 20.0;
        
       // we need to rotate 90 degrees because we're in landscape
        physicsWorld.gravity = vectorByRotatingVectorClockwise(grav)
        
        
        if PRINT_DEBUG_INFO{
            print("rotation=\(mm.rotation)")
            print("gravityVector=\(mm.gravityVector)")
            print("transform=\(mm.transform)") // transform is used in UIKit classes
        }
        
    }
    
    // MARK: - UIGestureRecognizerDelegate Methods -
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                    shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool{
                return true
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask |
            contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Target | PhysicsCategory.Objective {
            var player:SKNode
            if contact.bodyA.categoryBitMask == PhysicsCategory.Target {
                player = contact.bodyA.node!;
            } else {
                player = contact.bodyB.node!;
            }
        }
    }
    
    
}
