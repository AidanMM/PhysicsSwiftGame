
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
    var gameManager:GameViewController?
    var level:Int = 0
    var restartButton:SKSpriteNode?
    var backButton:SKSpriteNode?
    var portalA:Portal?
    var portalB:Portal?
    var firstPortal:Bool = false
    var timePassed:Float = 0
    var oldTime:CFTimeInterval?
    
    let shrinkAction = SKAction.sequence([
        //SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false),
        SKAction.scaleTo(0.25, duration: 0.1),
        SKAction.removeFromParent()
        ])
    
    // MARK: - Initialization -
    override func didMoveToView(view: SKView) {
        /*let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)*/
    
        playableRect = (gameManager?.determinePlayableRect(self))!
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
        
        //Set up gesture recognizer
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.handleSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view!.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.handleSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view!.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.handleSwipeGesture(_:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view!.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.handleSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view!.addGestureRecognizer(swipeDown)
        
        //Physics
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
        
        //Set up physiscs things
        physicsWorld.contactDelegate = self;
        
        //Set up animated end goal
        let node = childNodeWithName("//Objective") as! SKSpriteNode
        node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
        node.physicsBody!.dynamic = false
        node.physicsBody!.affectedByGravity = false
        node.physicsBody!.categoryBitMask = PhysicsCategory.Shape
        
        //Set up buttons on every game world for back and restart
        restartButton = SKSpriteNode(imageNamed: "Restart")
        restartButton?.setScale(0.7)
        restartButton!.position = CGPointMake(playableRect.origin.x + restartButton!.size.width / 2, playableRect.size.height + playableRect.origin.y - restartButton!.size.height / 2)
        backButton = SKSpriteNode(imageNamed: "Back")
        backButton?.setScale(0.7)
        backButton!.position = CGPointMake(playableRect.origin.x + playableRect.size.width - backButton!.size.width / 2, playableRect.size.height + playableRect.origin.y - backButton!.size.height / 2)
        
        addChild(restartButton!)
        addChild(backButton!)
    }
 
    override func update(currentTime: CFTimeInterval) {
        let mm = MotionManager.sharedMotionManager
        
         // make sure we're not on the simulator
        guard mm.gravityVector != CGVectorMake(0, 0) else{
            return
        }
        
        var grav = mm.gravityVector.normalized()
        grav.normalize()
        grav *= 20.0;
        
        // we need to rotate 90 degrees because we're in landscape
        physicsWorld.gravity = vectorByRotatingVectorClockwise(grav)
        
        
        if PRINT_DEBUG_INFO{
            print("rotation=\(mm.rotation)")
            print("gravityVector=\(mm.gravityVector)")
            print("transform=\(mm.transform)") // transform is used in UIKit classes
        }
        if oldTime != nil {
            timePassed += Float(currentTime - oldTime!)
        }
        oldTime = currentTime
        
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
                        self.portalA =  Portal(imageNamed: "Portal")
                        self.addChild(self.portalA!)
                    }
                    if self.portalB != nil && self.portalA?.otherPortal == nil {
                        self.portalA?.linkPortal(self.portalB!)
                    }
                    self.portalA?.initialize(node as! SKSpriteNode)
                } else {
                    self.firstPortal = false
                    if self.portalB == nil {
                        self.portalB =  Portal(imageNamed: "Portal")
                        self.addChild(self.portalB!)
                    }
                    self.portalB?.initialize(node as! SKSpriteNode)
                    if self.portalA?.otherPortal == nil {
                        self.portalA?.linkPortal(self.portalB!)
                    }
                }
                SKTAudio.sharedInstance().playSoundEffect("clickSparkle.mp3")
            }
        })
        
        if backButton!.containsPoint(positionInScene) {
            gameManager?.loadStageSelectScene()
            SKTAudio.sharedInstance().playSoundEffect("menuClick.wav")
        }
        if restartButton!.containsPoint(positionInScene) {
            gameManager?.loadGameScene(level)
            SKTAudio.sharedInstance().playSoundEffect("menuClick.wav")
        }
    }
    
    func handleSwipeGesture(gesture: UIGestureRecognizer) {
        /*if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            var grav:CGVector
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                grav = CGVectorMake(1.0, 0.0)
            case UISwipeGestureRecognizerDirection.Down:
                grav = CGVectorMake(0.0, -1.0)
            case UISwipeGestureRecognizerDirection.Left:
                grav = CGVectorMake(-1.0, 0.0)
            case UISwipeGestureRecognizerDirection.Up:
                grav = CGVectorMake(0.0, 1.0)
            default:
                grav = CGVectorMake(0.0, 0.0)
                break
            }
            grav *= 20;
            physicsWorld.gravity = grav
        }*/
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
                if level + 1 > gameManager?.highestLevel {
                    gameManager?.highestLevel = level + 1
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setInteger(level + 1, forKey: (gameManager?.highestLevelKey)!)
                }
                //See if we have a new high score
                //Check to see if we have any user data yet and load it.
                //first verify if the data exists at all
                let defaults = NSUserDefaults.standardUserDefaults()
                let num = defaults.floatForKey("\(level)")
                var bestSpeed:Float
                if num > 0 {
                    //The value exists so lets check it and see if we need to save a new high score
                    bestSpeed = num
                    if timePassed < bestSpeed {
                        //Write the new bestSpeed value
                        defaults.setFloat(timePassed, forKey: "\(level)")
                    }
                } else {
                    //There is no saved value for level progression so let's create one
                    defaults.setFloat(timePassed, forKey: "\(level)")
                }
                gameManager?.loadGameScene(level + 1)
            }
            if other.name == "portal" {
                (other as! Portal).telaportSprite(first);
            }
            
        }
    }
    
    
}
