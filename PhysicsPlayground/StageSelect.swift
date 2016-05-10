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
    var rightPageButton:SKSpriteNode?
    var leftPageButton:SKSpriteNode?
    var pageNumber = 1
    var playableRect = CGRectMake(0, 0, 0, 0)
    var buttons = [SKSpriteNode]()
    
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
        self.playableRect = playableRect
        backgroundColor = SKColor.blackColor()
        let background = SKSpriteNode(imageNamed: "SpecturmBackground")
        background.setScale(1.2)
        background.zPosition = -1
        background.position = CGPointMake(size.width / 2, size.height / 2)
        addChild(background)
        createLevelButtons(self.pageNumber)
        
        //Set up back and paging buttons
        backButton = SKSpriteNode(imageNamed: "Back")
        backButton?.setScale(0.7)
        backButton!.position = CGPointMake(playableRect.origin.x + playableRect.size.width - backButton!.size.width / 2, playableRect.size.height + playableRect.origin.y - backButton!.size.height / 2)
        addChild(backButton!)
        
        rightPageButton = SKSpriteNode(imageNamed: "RightPageArrow")
        rightPageButton?.setScale(0.7)
        rightPageButton!.position = CGPointMake(playableRect.origin.x + playableRect.size.width - rightPageButton!.size.width / 2, playableRect.origin.y + rightPageButton!.size.height / 2)
        addChild(rightPageButton!)
        if (pageNumber) * 5 + 1 > gameManager.NumLevels {
            rightPageButton?.hidden = true
        }
        
        leftPageButton = SKSpriteNode(imageNamed: "LeftPageArrow")
        leftPageButton?.setScale(0.7)
        leftPageButton!.position = CGPointMake(leftPageButton!.size.width / 2, playableRect.origin.y + leftPageButton!.size.height / 2)
        addChild(leftPageButton!)
        if pageNumber <= 1 {
            leftPageButton?.hidden = true
        }
        
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
        if leftPageButton!.containsPoint(positionInScene)  && !leftPageButton!.hidden{
            SKTAudio.sharedInstance().playSoundEffect("menuClick.wav")
            pageNumber -= 1
            createLevelButtons(pageNumber)
            if (pageNumber) * 5 + 1 > gameManager.NumLevels {
                rightPageButton?.hidden = true
            } else {
                rightPageButton?.hidden = false
            }
            if pageNumber <= 1 {
                leftPageButton?.hidden = true
            } else {
                leftPageButton?.hidden = false
            }
        }
        if rightPageButton!.containsPoint(positionInScene)  && !rightPageButton!.hidden{
            SKTAudio.sharedInstance().playSoundEffect("menuClick.wav")
            pageNumber += 1
            createLevelButtons(pageNumber)
            if (pageNumber) * 5 + 1 > gameManager.NumLevels {
                rightPageButton?.hidden = true
            } else {
                rightPageButton?.hidden = false
            }
            if pageNumber <= 1 {
                leftPageButton?.hidden = true
            } else {
                leftPageButton?.hidden = false
            }
        }
    }
    
    func createLevelButtons(pageNumber:Int){
        if buttons.count > 0 {
            for i in 0...buttons.count - 1{
                buttons[i].removeFromParent()
            }
        }
        buttons.removeAll()
        var page = pageNumber
        if page < 1 {
            page = 1
        }
        while (page - 1) * 5 + 1 > gameManager.NumLevels {
            page -= 1
        }
        let lower = min( ((page-1) * 5) + 5, gameManager.NumLevels)
        let offset = playableRect.size.width / CGFloat(lower - ((page-1) * 5))
        for i in ((page-1) * 5 + 1)...lower {
            let buttonVal = (i - 1) % 5 + 1
            let stageValue = SKSpriteNode(imageNamed: "\(buttonVal)")
            stageValue.name = "Button"
            stageValue.userData = NSMutableDictionary()
            stageValue.userData = ["levelIndex":Int(i)]
            stageValue.position = CGPointMake( playableRect.origin.x + offset * CGFloat(buttonVal - 1) + stageValue.size.width * 2,
                                               playableRect.origin.y + playableRect.size.height / 3)
            stageValue.colorBlendFactor = 1.0
            if i <= gameManager.highestLevel {
                stageValue.userData?.setObject(1, forKey: "valid")
                stageValue.color = SKColor.yellowColor()
            } else {
                stageValue.userData?.setObject(0, forKey: "valid")
                stageValue.color = SKColor.grayColor()
            }
            buttons.append(stageValue)
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
            buttons.append(starSprite)
            addChild(starSprite)
        }
        var StageSample:SKSpriteNode
        switch self.pageNumber {
        case 1:
            StageSample = SKSpriteNode(imageNamed: "CityScapeBackground")
            StageSample.size = CGSizeMake(400, 400)
        case 2:
            StageSample = SKSpriteNode(imageNamed: "NightCity")
            StageSample.size = CGSizeMake(400, 400)
        case 3:
            StageSample = SKSpriteNode(imageNamed: "CityScapeBackground")
            StageSample.size = CGSizeMake(400, 400)
        case 4:
            StageSample = SKSpriteNode(imageNamed: "CityScapeBackground")
            StageSample.size = CGSizeMake(400, 400)
        default:
            StageSample = SKSpriteNode(imageNamed: "CityScapeBackground")
            StageSample.size = CGSizeMake(400, 400)
        }
        StageSample.position = CGPointMake(playableRect.origin.x + playableRect.size.width / 2, playableRect.origin.y + playableRect.size.height / 3 * 2)
        addChild(StageSample)
        buttons.append(StageSample)
    }
}

