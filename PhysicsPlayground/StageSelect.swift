//
//  StageSelect.swift
//  PhysicsPlayground
//
//  Created by Aidan McInerny on 4/26/16.
//  Copyright © 2016 tony. All rights reserved.
//

import SpriteKit
class StageSelect:SKScene {
    let gameManager:GameViewController
    var backButton:SKSpriteNode?
    
    init(size: CGSize, scaleMode:SKSceneScaleMode, gameManager:GameViewController){
        self.gameManager = gameManager
        super.init(size: size)
        self.scaleMode = scaleMode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        let playableRect = gameManager.determinePlayableRect(self)
        backgroundColor = SKColor.blackColor()
        let background = SKSpriteNode(imageNamed: "StageSelectBackground")
        background.zPosition = -1
        background.position = CGPointMake(size.width / 2, size.height / 2)
        addChild(background)
        let offset = playableRect.size.width / CGFloat(gameManager.NumLevels)
        for i in 1...gameManager.NumLevels {
            let stageValue = SKSpriteNode(imageNamed: "\(i)")
            stageValue.name = "Button"
            stageValue.userData = NSMutableDictionary()
            stageValue.userData = ["levelIndex":Int(i)]
            stageValue.position = CGPointMake( playableRect.origin.x + offset * CGFloat(i - 1) + stageValue.size.width * 2,
                playableRect.origin.y + playableRect.size.height / 3)
            stageValue.colorBlendFactor = 1.0
            if i <= gameManager.highestLevel {
                stageValue.userData?.setObject(1, forKey: "valid")
                stageValue.color = SKColor.yellowColor()
            } else {
                stageValue.userData?.setObject(0, forKey: "valid")
                stageValue.color = SKColor.grayColor()
            }
            addChild(stageValue)
            
            //Next check to see if they completed the level in under 15 seconds and should get a star
            //30 seconds yields a star with a worse shade
            //Worse than 30 gets no stars
            let defaults = NSUserDefaults.standardUserDefaults()
            let num = defaults.floatForKey("\(i)")
            let starSprite = SKSpriteNode(imageNamed: "StarP")
            starSprite.position = CGPointMake(stageValue.position.x, stageValue.position.y - stageValue.size.height - starSprite.size.height)
            starSprite.setScale(4)
            if num == 0 || num > 10 {
                continue
            }
            else if num > 5 {
                starSprite.colorBlendFactor = 1.0
                starSprite.color = SKColor.grayColor()
            } else {
                //The sprite is already gold!
            }
            addChild(starSprite)
        }
        
        backButton = SKSpriteNode(imageNamed: "Back")
        backButton?.setScale(0.7)
        backButton!.position = CGPointMake(playableRect.origin.x + playableRect.size.width - backButton!.size.width / 2, playableRect.size.height + playableRect.origin.y - backButton!.size.height / 2)
        
        addChild(backButton!)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch:UITouch = touches.first!
        let positionInScene = touch.locationInNode(self)
        enumerateChildNodesWithName("Button", usingBlock: {node, _ in
            if node.containsPoint(positionInScene){
                if let userData = node.userData {
                    let valid = userData["valid"] as! Int
                    if valid > 0 && userData["levelIndex"] != nil {
                        SKTAudio.sharedInstance().playSoundEffect("menuClick.wav")
                        self.gameManager.loadGameScene( (userData["levelIndex"] as! Int))
                    }
                }
            }
        })
        if backButton!.containsPoint(positionInScene) {
            SKTAudio.sharedInstance().playSoundEffect("menuClick.wav")
            gameManager.loadHomeScene()
        }
    }
}

