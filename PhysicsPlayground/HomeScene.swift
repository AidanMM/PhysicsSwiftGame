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
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        gameManager.loadGameScene(5)
    }
}
