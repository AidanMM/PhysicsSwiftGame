//
//  EndScene.swift
//  PuzPortler
//
//  Created by Aidan McInerny on 5/17/16.
//  Copyright © 2016 tony. All rights reserved.
//

import SpriteKit
class EndScene:SKScene {
    let gameManager:GameViewController
    
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
        let background = SKSpriteNode(imageNamed: "StageSelect")
        background.zPosition = -1
        background.position = CGPointMake(size.width / 2, size.height / 2)
        background.setScale(1.2)
        addChild(background)
        let line1:SKLabelNode = SKLabelNode()
        line1.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        line1.fontSize = 100
        line1.fontName = "Copperplate"
        line1.text = "Thanks for Playing!"
        
        let line2:SKLabelNode = SKLabelNode()
        line2.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        line2.fontSize = 100
        line2.fontName = "Copperplate"
        
        let line3:SKLabelNode = SKLabelNode()
        line3.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        line3.fontSize = 100
        line3.fontName = "Copperplate"
        
        let line4:SKLabelNode = SKLabelNode()
        line4.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        line4.fontSize = 100
        line4.fontName = "Copperplate"
        
        //Now go through and count up the gold stars the player has earned and change their response based on that
        var count = 0
        for i in 0...gameManager.NumLevels {
            let defaults = NSUserDefaults.standardUserDefaults()
            let num = defaults.floatForKey("\(i)")
            if num < gameManager.goldTime {
                count += 1
            }
        }
        line2.fontSize = 70
        line3.fontSize = 70
        switch count {
        case 0...(gameManager.NumLevels / 2): //Less than half
            line2.text = "Did you know you can get Gold Stars for winning?"
            line3.text = "Beat a level in under \(gameManager.goldTime) seconds to get a gold star."
            break
        //less than 75%
        case (gameManager.NumLevels / 2)...(gameManager.NumLevels / 4 * 3): //Less than half
            line2.text = "You are starting to get pretty good!"
            line3.text = "Try to beat levels in under\(gameManager.goldTime) seconds to get a gold star."
            break
        // 75% to Max
        case (gameManager.NumLevels / 4 * 3)...(gameManager.NumLevels - 1): //Less than half
            line2.text = "You got most of the gold stars! Keep on Trying!"
            line3.text = "Just push for those last few!"
            break
        //All of them!
        case gameManager.NumLevels:
            line2.text = "You got all the gold Stars! Amazing Job!"
            line3.text = "I was pretty sure this wasn't even possible!"
            break
        default:
            line2.text = "Thanks for Playing! Great Job!"
            break
            
        }
        line4.text = "You got \(count) out of \(gameManager.NumLevels) Gold Stars!"
        
        
        line1.position = CGPointMake(size.width / 2, size.height / 2 - 200 + 400)
        addChild(line1)
        line2.position = CGPointMake(size.width / 2, size.height / 2  + 400)
        addChild(line2)
        line3.position = CGPointMake(size.width / 2, size.height / 2 - 100 + 400)
        addChild(line3)
        line4.position = CGPointMake(size.width / 2, size.height / 2 + 100 + 400)
        addChild(line4)
        
        let line5:SKLabelNode = SKLabelNode()
        line5.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        line5.fontSize = 70
        line5.fontName = "Copperplate"
        line5.text = "-From the games creator Aidan McInerny"
        
        line5.position = CGPointMake(size.width / 2, size.height / 2 - 300 + 400)
        addChild(line5)
        

        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        gameManager.loadHomeScene()
    }
}

