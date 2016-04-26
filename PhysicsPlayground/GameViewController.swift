//
//  GameViewController.swift
//  PhysicsPlayground
//
//  Created by jefferson on 3/1/16.
//  Copyright (c) 2016 tony. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var skView:SKView!
    let showDebugData = true
    let showPhysics = true
    let screenSize = CGSize(width:2048, height: 1536)
    let scaleMode = SKSceneScaleMode.AspectFill
    var gameScene:GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        //Load the home screen
        loadHomeScene()
    }
    
    // MARK: - Scene Navigation - 
    func loadHomeScene() {
        let scene = HomeScene(size:screenSize, scaleMode:scaleMode, gameManager: self)
        let reveal = SKTransition.crossFadeWithDuration(1)
        skView.presentScene(scene, transition: reveal)
    }
    
    func loadGameScene(level:Int){
        MotionManager.sharedMotionManager.startUpdates()
        
        gameScene = GameScene(fileNamed: "GameScene\(level)")!
        gameScene?.scaleMode = scaleMode
        gameScene?.level = level
        gameScene?.gameManager = self
        
        if showDebugData{
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
        
        if showPhysics{
            skView.showsPhysics = true
        }
        
        let reveal = SKTransition.doorsOpenHorizontalWithDuration(1)
        skView.presentScene(gameScene!, transition: reveal)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
           gameScene?.shake()
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
       return .Landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    
   }
