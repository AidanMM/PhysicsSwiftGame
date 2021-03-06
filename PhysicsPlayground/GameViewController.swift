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
    let showDebugData = false
    let showPhysics = false
    let screenSize = CGSize(width:2048, height: 1536)
    let scaleMode = SKSceneScaleMode.AspectFill
    let highestLevelKey:String = "highestLevel"
    let NumLevels:Int = 20;
    var gameScene:GameScene?
    var highestLevel:Int = 0
    var area = 0
    var goldTime:Float = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        
        //Check to see if we have any user data yet and load it.
        let defaults = NSUserDefaults.standardUserDefaults()
        let num = defaults.integerForKey(highestLevelKey)
        if num > 0 {
            //The value exists so lets use it
            highestLevel = num
        } else {
            //There is no saved value for level progression so let's create one
            defaults.setInteger(1, forKey: highestLevelKey)
            highestLevel = 1
        }
    SKTAudio.sharedInstance().playBackgroundMusic("HomeScreenTheme.wav")
        //Load the home screen
        //loadHomeScene()
        loadHomeScene()
    }
    
    // MARK: - Scene Navigation - 
    func loadHomeScene() {
        let scene = HomeScene(size:screenSize, scaleMode:scaleMode, gameManager: self)
        let reveal = SKTransition.crossFadeWithDuration(1)
        skView.presentScene(scene, transition: reveal)
        SKTAudio.sharedInstance().playBackgroundMusic("HomeScreenTheme.wav")
    }
    
    func loadEndScene() {
        let scene = EndScene(size:screenSize, scaleMode:scaleMode, gameManager: self)
        let reveal = SKTransition.crossFadeWithDuration(1)
        skView.presentScene(scene, transition: reveal)
        SKTAudio.sharedInstance().playBackgroundMusic("BossMusic.wav")
    }
    
    func loadStageSelectScene() {
        let scene = StageSelect(size:screenSize, scaleMode:scaleMode, gameManager: self)
        let reveal = SKTransition.crossFadeWithDuration(0.5)
        skView.presentScene(scene, transition: reveal)
        SKTAudio.sharedInstance().playBackgroundMusic("Credits.wav")
    }
    
    func loadGameScene(level:Int){
        //If we are going to hit a level that doesn't exist, stop that!
        if level > NumLevels {
            loadEndScene()
            return;
        }
        let nextLevel = "GameScene\(level)"
        
        MotionManager.sharedMotionManager.startUpdates()
        gameScene = GameScene(fileNamed: nextLevel)!
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
        
        //Play the corresponding music for the given area
        var areaFromLevel = ((level - 1) / 5) + 1
        if areaFromLevel != area {
            area = areaFromLevel
            switch area {
            case 1:
                SKTAudio.sharedInstance().playBackgroundMusic("Area1.wav")
            case 2:
                SKTAudio.sharedInstance().playBackgroundMusic("Area2.wav")
            case 3:
                SKTAudio.sharedInstance().playBackgroundMusic("Area3.wav")
            case 4:
                SKTAudio.sharedInstance().playBackgroundMusic("Area4.wav")
            default:
                SKTAudio.sharedInstance().playBackgroundMusic("HomeScreenTheme.wav")
            }
        }
        
        let reveal = SKTransition.doorsOpenHorizontalWithDuration(1)
        skView.presentScene(gameScene!, transition: reveal)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
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
    
    // MARK: - Helper Functions -
    func determinePlayableRect(scene:SKScene) -> CGRect {
        // Calculate playable margin for landscape
        let maxAspectRatio: CGFloat = 16.0/9.0 // iPhone 5
        let maxAspectRatioHeight = scene.size.width / maxAspectRatio
        let playableMargin: CGFloat = (scene.size.height - maxAspectRatioHeight)/2
        return CGRect(x: 0, y: playableMargin,
                              width: scene.size.width, height: scene.size.height-playableMargin*2)
    }
    
   }
