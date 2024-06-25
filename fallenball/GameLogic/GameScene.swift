//
//  GameScene.swift
//  fallenball
//
//  Created by Vlad Kuzmenko on 23.06.2024.
//

import SpriteKit
import GameplayKit
import CoreMotion




class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let ballCategory: UInt32 = 0x1 << 0
    let tileCategory: UInt32 = 0x2 << 2
    let fireCategory: UInt32 = 0x3 << 3
    
    var gameViewController: GameViewController?
    var ball: SKSpriteNode!
    var backgroundNode1: SKSpriteNode!
    var backgroundNode2: SKSpriteNode!
    let ballFallingSpeed: CGFloat = 200.0
    let backgroundSpeedDifference: CGFloat = 25.0
    var gameOverState = true
    var motionManager = CMMotionManager()
    var accelerometrByX: CGFloat = 0
    var timeLeftLabel: SKLabelNode!
    var timeToWin = 30
    var timerToEndGame: Timer?
    var gameOverLabel: SKLabelNode!
    var isWin = false
    var buttonStart: SKSpriteNode!
    var timerState = false
    var flame = false
    let fireTextures = [SKTexture(image: .fire1), SKTexture(image: .fire2), SKTexture(image: .fire3) ,SKTexture(image: .fire4), SKTexture(image: .fire5), SKTexture(image: .fire6), SKTexture(image: .fire7)]
    let ballFlameTextures = [SKTexture(image: .fBall1), SKTexture(image: .fBall2), SKTexture(image: .fBall3) ,SKTexture(image: .fBall4), SKTexture(image: .fBall5), SKTexture(image: .fBall6), SKTexture(image: .fBall7), SKTexture(image: .fBall8)]
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.speed = 0
        isPaused = true
        
        createStartButton()
        createAccelerometr()
        setupBackground()
        setupBall()
        spawnPads()

    }
    
    //MARK: Create accelerometer
    func createAccelerometr() {
        motionManager.accelerometerUpdateInterval = 0.2
        guard let operationQueue = OperationQueue.current else {return}
        motionManager.startAccelerometerUpdates(to: operationQueue) { [self] (accelerometerData, error) in
            guard let accelerometerData = accelerometerData else {
                print("Error: \(error!)")
                return
            }
            let acceleration = accelerometerData.acceleration
            self.accelerometrByX = CGFloat(acceleration.x) * 0.75 + self.accelerometrByX * 0.25
            
        }
    }
    // MARK: Create Timer, win condition
    func timerLabelAndTimerSetup() {
        timeLeftLabel =  SKLabelNode()
        timeLeftLabel.text = "Time left:\(timeToWin)"
        timeLeftLabel.fontColor = .red
        timeLeftLabel.horizontalAlignmentMode = .center
        timeLeftLabel.fontSize = 30
        timeLeftLabel.fontName = "Arial-Bold"
        timeLeftLabel.position = CGPoint(x: size.width / 2  , y: size.height - 50)
        if UIScreen.main.bounds.size.height > 750 {
            timeLeftLabel.position = CGPoint(x: size.width / 2  , y: size.height - 80)
        }
        addChild(timeLeftLabel)
        timerToEndGame = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        timeToWin -= 1
        timeLeftLabel.text = "Time left:\(timeToWin)"
        if timeToWin <= 0 {
            stopTimer()
            gameOver()
        }
    }
    
    func stopTimer() {
        timerToEndGame?.invalidate()
        timerToEndGame = nil
    }
    
    //MARK: Create BackGround
    
    func setupBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        backgroundNode1 = SKSpriteNode(texture: backgroundTexture)
        backgroundNode1.size = CGSize(width: frame.width, height: frame.height)
        backgroundNode1.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(backgroundNode1)
        backgroundNode2 = SKSpriteNode(texture: backgroundTexture)
        backgroundNode2.size = CGSize(width: frame.width, height: frame.height)
        backgroundNode2.position = CGPoint(x: frame.midX, y: frame.midY - frame.height + 1)
        addChild(backgroundNode2)
        
        let moveUp = SKAction.moveBy(x: 0, y: frame.height, duration: TimeInterval((frame.height + backgroundSpeedDifference) / ballFallingSpeed))
        let resetPosition = SKAction.moveBy(x: 0, y: -frame.height, duration: 0)
        let moveForever = SKAction.repeatForever(SKAction.sequence([moveUp, resetPosition]))
        
        backgroundNode1.run(moveForever)
        backgroundNode2.run(moveForever)
    }
    
    
    
    //MARK: Create Ball
    
    func setupBall() {
        ball = SKSpriteNode(imageNamed: "ball")
        ball.size = CGSize(width: 50, height: 50)
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.contactTestBitMask = tileCategory
        ball.physicsBody?.collisionBitMask = tileCategory
        ball.physicsBody?.restitution = 0.5
        ball.physicsBody?.friction = 0.2
        addChild(ball)
        let fallForever = SKAction.repeatForever(SKAction.moveBy(x: 0, y: -ballFallingSpeed, duration: 1))
        ball.run(fallForever)
    }
    
    //MARK: Random Spawn Pads
    func spawnPads() {
        let spawn = SKAction.run { [self] in
            
            
            let pad = SKSpriteNode(imageNamed: "pad")
            pad.name = "pad"
            pad.size = CGSize(width: size.width - ball.size.width - 20, height: 30)
            var xPosition: CGFloat = 0.0
            var anchorPoint: CGPoint!
            let randomInt = Int.random(in: 0...300)
            switch randomInt {
            case 0...50:
                xPosition = self.size.width
                anchorPoint = CGPoint(x: 1.0, y: 0.5)
                pad.physicsBody = SKPhysicsBody(rectangleOf: pad.size, center: CGPoint(x:  -pad.size.width / 2, y: 0))
            case 51...100:
                anchorPoint = CGPoint(x: 0.0, y: 0.5)
                xPosition = 0.0
                pad.physicsBody = SKPhysicsBody(rectangleOf: pad.size, center: CGPoint(x: pad.size.width / 2, y: 0))
                
            case 101...150:
                xPosition = self.size.width
                anchorPoint = CGPoint(x: 1.0, y: 0.5)
                pad.physicsBody = SKPhysicsBody(rectangleOf: pad.size, center: CGPoint(x:  -pad.size.width / 2, y: 0))
                createFire(pad, CGPoint(x: -40, y: pad.size.height))
            case 151...200:
                anchorPoint = CGPoint(x: 0.0, y: 0.5)
                xPosition = 0.0
                pad.physicsBody = SKPhysicsBody(rectangleOf: pad.size, center: CGPoint(x: pad.size.width / 2, y: 0))
                createFire(pad, CGPoint(x: 40, y: pad.size.height))
            case 201...250:
                xPosition = self.size.width
                anchorPoint = CGPoint(x: 1.0, y: 0.5)
                pad.physicsBody = SKPhysicsBody(rectangleOf: pad.size, center: CGPoint(x:  -pad.size.width / 2, y: 0))
                createMovePlatformAction(pad, anchorPoint)
            case 251...300:
                anchorPoint = CGPoint(x: 0.0, y: 0.5)
                xPosition = 0.0
                pad.physicsBody = SKPhysicsBody(rectangleOf: pad.size, center: CGPoint(x: pad.size.width / 2, y: 0))
                createMovePlatformAction(pad, anchorPoint)
            default: break
            }
            
            pad.position = CGPoint(x: xPosition, y: -pad.size.height)
            pad.anchorPoint = anchorPoint
            
            pad.physicsBody?.isDynamic = false
            pad.physicsBody?.categoryBitMask = self.tileCategory
            pad.physicsBody?.contactTestBitMask = self.ballCategory
            pad.physicsBody?.collisionBitMask = self.ballCategory
            self.addChild(pad)
            
            let moveUp = SKAction.moveBy(x: 0, y: self.frame.height + pad.size.height + self.backgroundSpeedDifference, duration: TimeInterval((self.frame.height + self.backgroundSpeedDifference) / self.ballFallingSpeed))
            let remove = SKAction.removeFromParent()
            pad.run(SKAction.sequence([moveUp, remove]))
        }
        let delay = SKAction.wait(forDuration: 1)
        let spawnForever = SKAction.repeatForever(SKAction.sequence([spawn, delay]))
        run(spawnForever)
    }
    
    //MARK: Create Fire
    
    func createFire(_ padNode: SKSpriteNode, _ position: CGPoint) {
        let texture = SKTexture(image: .fire1)
        let fireNode = SKSpriteNode(texture: texture)
        fireNode.anchorPoint = padNode.anchorPoint
        fireNode.position = position
        fireNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: fireNode.size.width / 2, height: fireNode.size.height / 2.5))
        fireNode.physicsBody?.isDynamic = false
        fireNode.physicsBody?.categoryBitMask = self.fireCategory
        fireNode.physicsBody?.contactTestBitMask = self.ballCategory
        fireNode.physicsBody?.collisionBitMask = self.ballCategory
        let fireAnimate = SKAction.animate(with: fireTextures, timePerFrame: 0.1)
        fireNode.run(SKAction.repeatForever(fireAnimate))
        padNode.addChild(fireNode)
    }
    
    func createMovePlatformAction(_ pad: SKSpriteNode, _ ancorPoin: CGPoint) {
        
        let moveAction = SKAction.moveBy(x: ball.size.width + 20, y: 0, duration: 1)
        let moveActionBack = SKAction.moveBy(x: -ball.size.width - 20, y: 0, duration: 1)
        let waitAction = SKAction.wait(forDuration: 1.5)
        let sequenceForward = SKAction.sequence([moveAction, waitAction, moveActionBack, waitAction])
        let sequencrBackward = SKAction.sequence([moveActionBack, waitAction, moveAction, waitAction])
        if ancorPoin == CGPoint(x: 0.0, y: 0.5) {
            pad.run(SKAction.repeatForever(sequenceForward))
        } else {
            pad.run(SKAction.repeatForever(sequencrBackward))
        }
    }
    
    
    //MARK: Create Start Button
    
    func createStartButton() {
        buttonStart = SKSpriteNode(imageNamed: "buttonStart")
        buttonStart.position = CGPoint(x: size.width / 2, y: size.height / 2)
        buttonStart.zPosition = 100
        addChild(buttonStart)
    }
    
    
    //MARK: Touches, Physics, Update
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startGame()
    }
    
   private func startGame() {
            gameOverState = false
            physicsWorld.speed = 1
            isPaused = false
            buttonStart.isHidden = true
            if !timerState {
                timerLabelAndTimerSetup()
                timerState = true
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == (ballCategory | tileCategory) {
            let ballNode = contact.bodyA.categoryBitMask == ballCategory ? contact.bodyA.node : contact.bodyB.node
            if let ballNode = ballNode {
                ballNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
        }
        if contactMask == (ballCategory | fireCategory) {
            let ballNode = contact.bodyA.categoryBitMask == ballCategory ? contact.bodyA.node : contact.bodyB.node
            if let ballNode = ballNode {
                if !flame {
                    flame = true
                    accelerometrByX = 0
                    ballNode.zRotation = 0
                    ballNode.run(SKAction.animate(with: ballFlameTextures, timePerFrame: 0.1)) { [self] in
                        ballNode.removeFromParent()
                        gameOver()
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !gameOverState{
            if ball.position.y > size.height {
                stopTimer()
                gameOver()
            }
        }
    }
    
    
    override func didSimulatePhysics() {
        guard let body = ball.physicsBody else{return}
        body.velocity = CGVector(dx: accelerometrByX * 1000, dy:  0)
        if ball.position.y < 10 {
            ball.position = CGPoint(x: ball.position.x, y: 10)
        } else if ball.position.x < 10 {
            ball.position = CGPoint(x: 10, y: ball.position.y)
        } else if ball.position.x > size.width - 10 {
            ball.position = CGPoint(x: size.width - 10, y: ball.position.y)
        }
    }
    
    
    //MARK: Game Over, Restart
  private func gameOver() {
        gameOverState  =  true
        ball.removeFromParent()
        backgroundNode1.removeAllActions()
        backgroundNode2.removeAllActions()
        removeAllActions()
        enumerateChildNodes(withName: "pad") {
            name, stop in
            name.removeFromParent()
        }
        if timeToWin <= 0 {
            isWin = true
        } else {
            isWin = false
        }
        showAfterResultGameViewController()
    }
    
    
    
  func restartTheGame() {
        removeAllChildren()
        removeAllActions()
        if let scene = self.scene {
            let newGameScene = GameScene(size: scene.size)
            newGameScene.gameViewController = gameViewController
            if let view = self.view {
                view.presentScene(newGameScene)
            }
        }
    }
    
    
    
   private func showAfterResultGameViewController() {
        let gameOverVC = GameOverViewController()
        gameOverVC.isWinner = isWin
        gameOverVC.gameScene = self
        if let navigationController = self.view?.window?.rootViewController as? UINavigationController {
            navigationController.pushViewController(gameOverVC, animated: true)
        }
    }
    
}


