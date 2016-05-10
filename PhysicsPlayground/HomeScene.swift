 //
//  HomeScene.swift
//  PhysicsPlayground
//
//  Created by Aidan McInerny on 4/24/16.
//  Copyright © 2016 tony. All rights reserved.
//

import SpriteKit
class HomeScene:SKScene {
    let gameManager:GameViewController
    var playButton:SKSpriteNode?
    var stageSelectButon:SKSpriteNode?
    
    init(size: CGSize, scaleMode:SKSceneScaleMode, gameManager:GameViewController){
        self.gameManager = gameManager
        super.init(size: size)
        self.scaleMode = scaleMode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.purpleColor()
        let background = SKSpriteNode(imageNamed: "SpecturmBackground")
        background.zPosition = -1
        background.position = CGPointMake(size.width / 2, size.height / 2)
        background.setScale(1.2)
        addChild(background)
        
        playButton = SKSpriteNode(imageNamed: "PlayButton")
        playButton?.position = CGPointMake(size.width / 2, size.height / 2)
        playButton?.setScale(3.0)
        playButton?.colorBlendFactor = 1.0
        playButton?.color = SKColor.blackColor()
        stageSelectButon = SKSpriteNode(imageNamed: "StageSelectButton")
        stageSelectButon?.position = CGPointMake(size.width / 2, size.height / 2 - size.height / 5)
        stageSelectButon?.setScale(3.0)
        stageSelectButon?.colorBlendFactor = 1.0
        stageSelectButon?.color = SKColor.blackColor()
        
        addChild(playButton!)
        addChild(stageSelectButon!)

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch:UITouch = touches.first!
        let positionInScene = touch.locationInNode(self)
        if playButton!.containsPoint(positionInScene) {
            gameManager.loadGameScene(gameManager.highestLevel)
            SKTAudio.sharedInstance().playSoundEffect("menuClick.wav")
        }
        else if stageSelectButon!.containsPoint(positionInScene) {
            gameManager.loadStageSelectScene()
            SKTAudio.sharedInstance().playSoundEffect("menuClick.wav")
        }
    }
}
