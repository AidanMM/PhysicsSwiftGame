
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

protocol CustomNodeEvents{
    func didMoveToView()
}

class GameScene: SKScene,UIGestureRecognizerDelegate,SKPhysicsContactDelegate {
    var playableRect:CGRect = CGRectZero
    var gameManager:GameViewController?
    var level:Int = 0
    var portalA:Portal?
    var portalB:Portal?
    var firstPortal:Bool = false
    
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
        
        //Set up physiscs things
        physicsWorld.contactDelegate = self;
        
        let node = childNodeWithName("//Objective") as! SKSpriteNode
        node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
        node.physicsBody!.dynamic = false
        node.physicsBody!.affectedByGravity = false
        node.physicsBody!.categoryBitMask = PhysicsCategory.Shape
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch:UITouch = touches.first!
        let positionInScene = touch.locationInNode(self)
        
        enumerateChildNodesWithName("Wall", usingBlock: {node, _ in
            if node.containsPoint(positionInScene) {
                if self.firstPortal == false{
                    self.firstPortal = true
                    if self.portalA == nil {
                        self.portalA =  Portal(imageNamed: "square")
                        self.addChild(self.portalA!)
                    }
                    if self.portalB != nil && self.portalA?.otherPortal == nil {
                        self.portalA?.linkPortal(self.portalB!)
                    }
                    self.portalA?.initialize(node as! SKSpriteNode)
                } else {
                    self.firstPortal = false
                    if self.portalB == nil {
                        self.portalB =  Portal(imageNamed: "square")
                        self.addChild(self.portalB!)
                    }
                    self.portalB?.initialize(node as! SKSpriteNode)
                    if self.portalA?.otherPortal == nil {
                        self.portalA?.linkPortal(self.portalB!)
                    }
                }
            }
        })
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask |
            contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Target | PhysicsCategory.Objective {
            var first:SKSpriteNode
            var other:SKSpriteNode
            if contact.bodyA.categoryBitMask == PhysicsCategory.Target {
                first = contact.bodyA.node as! SKSpriteNode
                other = contact.bodyB.node as! SKSpriteNode
            } else {
                first = contact.bodyB.node as! SKSpriteNode
                other = contact.bodyA.node as! SKSpriteNode
            }
            
            if other.name == "Objective" && first.name == "target" {
                gameManager?.loadGameScene(level + 1)
            }
            if other.name == "portal" {
                (other as! Portal).telaportSprite(first);
            }
            
        }
    }
    
    
}
