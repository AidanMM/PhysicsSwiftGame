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
    var scene = GameScene()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.becomeFirstResponder()
        scene = GameScene(fileNamed:"GameScene")!
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
       // skView.showsPhysics = true // uncomment to see a memory leak!
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        MotionManager.sharedMotionManager.startUpdates()
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
           scene.shake()
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
