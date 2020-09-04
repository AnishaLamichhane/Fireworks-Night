//
//  GameScene.swift
//  project20
//
//  Created by Anisha Lamichhane on 8/27/20.
//  Copyright © 2020 Anisha Lamichhane. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    var gameTimer: Timer?
    var fireWorks = [SKNode]()
    var scoreLabel: SKLabelNode!
    var fireworkCreated = 0
    
    var leftEdge = -22
    var rightEdge = 1024 + 22
    var bottomedge = -22
    
    var score = 0 {
        didSet {
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
            background.position = CGPoint(x: 512, y: 384)
            background.blendMode = .replace
            background.zPosition = -1
            addChild(background)
        gameTimer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    
    
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800
        switch Int.random(in: 0...3) {
        case 0:
            // fire five , straight up
            createFireworks(xMovement: 0, x: 512 , y: bottomedge)
            createFireworks(xMovement: 0, x: 512 - 200 , y: bottomedge)
            createFireworks(xMovement: 0, x: 512 - 100 , y: bottomedge)
            createFireworks(xMovement: 0, x: 512 + 100, y: bottomedge)
            createFireworks(xMovement: 0, x: 512 + 200 , y: bottomedge)
        
        case 1:
//            fire five , in a fan
            createFireworks(xMovement: 0, x: 512 , y: bottomedge)
            createFireworks(xMovement: -200, x: 512 - 200 , y: bottomedge)
            createFireworks(xMovement: -100, x: 512 - 100 , y: bottomedge)
            createFireworks(xMovement: 100, x: 512 + 200 , y: bottomedge)
            createFireworks(xMovement: 200, x: 512 + 100 , y: bottomedge)
            
        case 2:
//            fire five , from left to the right
            createFireworks(xMovement: movementAmount, x: leftEdge , y: bottomedge + 400)
            createFireworks(xMovement: movementAmount, x: leftEdge , y: bottomedge + 300)
            createFireworks(xMovement: movementAmount, x: leftEdge , y: bottomedge + 200)
            createFireworks(xMovement: movementAmount, x: leftEdge , y: bottomedge + 100)
            createFireworks(xMovement:movementAmount, x: leftEdge, y: bottomedge)
            
        case 3:
//            fire five ,  from right to the left
            createFireworks(xMovement: -movementAmount, x: rightEdge , y: bottomedge + 400)
            createFireworks(xMovement: -movementAmount, x: rightEdge , y: bottomedge + 300)
            createFireworks(xMovement: -movementAmount, x: rightEdge , y: bottomedge + 200)
            createFireworks(xMovement: -movementAmount, x: rightEdge , y: bottomedge + 100)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomedge)
            
        default:
            break;
        }
        
    }
    
    func createFireworks(xMovement: CGFloat, x: Int, y: Int){
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .red
        default:
            firework.color = .green
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 110)
        node.run(move)
        
        let emitter = SKEmitterNode(fileNamed: "fuse")!
        emitter.position = CGPoint(x: 0 ,y: -22)
        node.addChild(emitter)
        
        fireWorks.append(node)
        addChild(node)
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else{ continue }
            
            for parent in fireWorks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue}
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireWorks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireWorks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func explode(firework: SKNode) {
        let emitter = SKEmitterNode(fileNamed: "explode")!
        emitter.position = firework.position
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0

        for (index, fireworkContainer) in fireWorks.enumerated().reversed() {
            let firework = fireworkContainer.children[0] as! SKSpriteNode

            if firework.name == "selected" {
                // destroy this firework!
                explode(firework: fireworkContainer)
                fireWorks.remove(at: index)
                numExploded += 1
            }
        }

        switch numExploded {
        case 0:
            // nothing – rubbish!
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }

}
