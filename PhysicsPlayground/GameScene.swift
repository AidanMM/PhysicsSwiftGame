
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
        
        // directional arrow
        let arrow = SKSpriteNode(imageNamed: "arrow")
        arrow.name = "arrow"
        arrow.position = CGPointMake(CGRectGetMidX(playableRect) , CGRectGetMinY(playableRect) + arrow.size.height)
        arrow.zPosition = SpriteLayer.HUD
        arrow.alpha = 0.6
        addChild(arrow)
        
        // Other shapes
        square.name = "shape"
        square.setScale(2.0)
        square.position = CGPoint(x: playableRect.width * 0.25, y: playableRect.height * 0.50)
        square.zPosition = SpriteLayer.Sprite
        
        addChild(square)
        
        // Physics
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
        square.physicsBody = SKPhysicsBody(rectangleOfSize: square.frame.size)
        
        //Set up physiscs things
        physicsWorld.contactDelegate = self;
        
        // setting up the contact delegates
        arrow.physicsBody?.categoryBitMask = PhysicsCategory.Shape
        square.physicsBody?.categoryBitMask = PhysicsCategory.Shape
        
        //load in a shader that I made
        let shader = SKShader(fileNamed: "TintRed.fsh")
        arrow.shader = shader;
            
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
     
        if let arrow = childNodeWithName("arrow"){
            // have the arrow point "up"
            // we need to rotate 90 degrees because we're in landscape
            arrow.zRotation = mm.rotation + CGFloat(M_PI_2)
        }
        
        var grav = mm.gravityVector.normalized()
        if abs(grav.dx) > abs(grav.dy) {
            grav.dy = 0
        } else if abs(grav.dy) > abs(grav.dx) {
            grav.dx = 0
        }
        grav.normalize()
        grav *= 9.8;
        
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
        if collision == PhysicsCategory.Shape | PhysicsCategory.Target {
            print("A shape hit the target!")
            
            // which physicsBody belongs to a shape?
            var shapeNode:SKNode?
            if contact.bodyA.categoryBitMask == PhysicsCategory.Shape{
                shapeNode = contact.bodyA.node
            } else {
                shapeNode = contact.bodyB.node
            }
            
            // bail out if the shapeNode isn't in the scene anymore
            guard shapeNode != nil else {
                print("ShapeNode is nil, so it has already been removed for some reason!")
                return
            }
            
            // cast the SKNode to an SKSpriteNode
            if let spriteNode = shapeNode as? SKSpriteNode{
                
                var isActive:Bool = false
                
                // does the userData dictionary exist?
                if let userData = spriteNode.userData{
                    // does the "active" key exist?
                    if userData["active"] != nil {
                        //grab the value
                        isActive = userData["active"] as! Bool
                    }
                }
                
                if isActive{
                    print("DO NOT runAction() on \(spriteNode.name!)")
                }else{
                    // set "active" to true so we only run the action once
                    spriteNode.userData = NSMutableDictionary()
                    spriteNode.userData = ["active":true]
                    
                    if spriteNode.name == "square"{
                        spriteNode.runAction(shrinkAction)
                    } else {
                        let bounceAction = SKAction.sequence([
                            //SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false),
                            SKAction.runBlock({print("bounce")}),
                            SKAction.applyImpulse(CGVectorMake(-500, -500), duration: 0.1),
                            SKAction.waitForDuration(0.5),
                            SKAction.runBlock({
                                    print("reset active on \(spriteNode.name)")
                                    spriteNode.userData = ["active":false]
                                })
                            ])
                        
                        spriteNode.runAction(bounceAction)
                    }
                    
                    print("runAction() on \(spriteNode.name!)")
                }
                
            }
        }
    }
    
    
}
