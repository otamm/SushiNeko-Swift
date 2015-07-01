import Foundation;


// side of the screen being tapped OR side of the screen where chopstick will be randomly positioned
enum Side {
    case Left, Right, None;
}

// represents possible game states
enum GameState {
    case Title, Ready, Playing, GameOver;
}

class MainScene: CCNode {
    /* custom variables */
    
    // an array to hold Piece class instances
    var pieces:[Piece] = [];
    
    // last piece to be generated. Set to 'left' so first piece will always be a .None
    var pieceLastSide: Side = .Left;
    
    // tracks index of current piece in 'pieces' array
    var pieceIndex = 0;
    
    // tracks if game is over, makes restart button visible.
    //var gameOver = false;
    
    // substitutes (and adds to) gameOver variable since the gameState will serve to signalize a gameOver also. Initially set to title.
    var gameState:GameState = .Title;
    
    // keeps track of time left for user to make a move. Must gradually increase the decreasing speed.
    var timeLeft: Float = 5 {
        didSet {
            self.timeLeft = max(min(self.timeLeft, 10), 0); // clamps time between 0 and 10
            self.lifeBar.scaleX = self.timeLeft / Float(10); // sets scaleX of lifeBar as a percentage of time over 10 (height of tower)
        }
    }
    
    // keeps track of score.
    var score = 0;
    
    // gets position of current piece instance being animated
    var addPiecesPosition: CGPoint?;
    
    
    /* code connections; variables must have 'weak' before being declared because they are only pointing to a reference of the object, not storing the actual data. */
    
    // a reserved space that'll contain Piece objects, displaying them there and positioning relative to the node space.
    weak var piecesNode:CCNode!;
    
    // the character instance for the game session
    weak var character:Character!;
    
    // restart button, initially invisible.
    weak var restartButton:CCButton!;
    
    // the red part of the life bar, the one which keeps track of the life remaining and shows it to the user.
    weak var lifeBar:CCSprite!;
    
    // displays score
    weak var scoreLabel:CCLabelTTF!;
    
    // content node for 'left' and 'right' buttons
    weak var tapButtons:CCNode!;
    /** methods **/
    
    
    /* cocos2d methods */
    
    // when a SpriteBuilder object is created, order of method calls is init(), didLoadFromCCB() and finally onEnter().
    override func onEnter() {
        super.onEnter();
        self.addPiecesPosition = self.piecesNode.positionInPoints;
    }
    
    // sets up MainScene, executed first
    func didLoadFromCCB() {
        var pieceYPosition:CGFloat = -30;
        
        // adds 10 pieces to scene
        for i in 0..<10 {
            var piece = CCBReader.load("Piece") as! Piece;
            self.pieceLastSide = piece.setObstacle(pieceLastSide); // both randomizes current chopstick side and updates value of pieceLastSide
            
            // position will be relative to 'piecesNode' container.
            piece.position = CGPoint(x:0 ,y:CGFloat(pieceYPosition));
            pieceYPosition += piece.contentSizeInPoints.height;
            self.piecesNode.addChild(piece);
            self.pieces.append(piece);
        }
        self.userInteractionEnabled = true;
    }
    
    // executed once restartButton is touched. Does not make sense to go all over again trigering all the 'start' animations, so it sets the gameState to .Ready
    func restart() {
        //var scene = CCBReader.loadAsScene("MainScene")
        //CCDirector.sharedDirector().presentScene(scene)
        // updated functionality to load game from .Ready state:
        var mainScene = CCBReader.load("MainScene") as! MainScene;
        mainScene.ready(); // equivalent to pressing the 'ready' button at the title.
        
        var scene = CCScene();
        scene.addChild(mainScene);
        
        var transition = CCTransition(fadeWithDuration: 0.3);
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition);
    }
    
    // executed at every frame, updates time and checks if time has ran out
    override func update(delta: CCTime) {
        if (self.gameState != .Playing) { return; };
        self.timeLeft -= Float(delta)
        if (self.timeLeft == 0) { // safe to check for 0 equality after clamping
            self.triggerGameOver();
        }
    }
    
    // called by 'play' button on .Title state of MainScene; updates game state, runs sequence of animations and then fades in buttons (enables their opacity, checks to 0 and gradually increases it to 1 in an interval of 0.2 second)
    func ready() {
        self.gameState = .Ready;
        self.animationManager.runAnimationsForSequenceNamed("Ready");
        
        self.tapButtons.cascadeOpacityEnabled = true; // if set to false, cascade opacity changes are not passed to child nodes.
        self.tapButtons.opacity = 0.0;
        self.tapButtons.runAction(CCActionFadeIn(duration: 0.2));
    }
    
    /* iOS methods */
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        // executed when, after cutting the sushi tree, a chopstick piece touches the player on the same side.
        if (self.gameState == .GameOver || gameState == .Title) { return; };
        if (self.gameState == .Ready) { self.start(); }
        if (touch.locationInWorld().x < (CCDirector.sharedDirector().viewSize().width / 2)) {
            self.character.left();
        } else {
            self.character.right();
        }
        // executed when, after cutting the sushi tree, a chopstick piece touches the player who has just moved to the opposite side.
        if (self.isGameOver()) { return; }; // returns Void, interrupting the method execution.
        self.character.tap(); // triggers 'scratch' sequence
        self.stepTower();
    }
    
    /* custom methods */
    
    // moves current piece to top of the tower, increments its zIndex by 1, randomizes its chopsticks and moves 'piecesNode' down by the size of a piece.
    func stepTower() {
        var piece = self.pieces[self.pieceIndex];
        self.addHitPiece(piece.side);
        var yDiff = piece.contentSize.height * 10;
        
        piece.position = ccpAdd(piece.position, CGPoint(x: 0, y: yDiff));
        
        piece.zOrder = piece.zOrder + 1;
        
        self.pieceLastSide = piece.setObstacle(pieceLastSide);
        
        //self.piecesNode.position = ccpSub(self.piecesNode.position,
        //    CGPoint(x: 0, y: piece.contentSize.height));
        var movePiecesDown = CCActionMoveBy(duration: 0.15, position: CGPoint(x: 0, y: -piece.contentSize.height));
        
        self.piecesNode.runAction(movePiecesDown);
        
        self.pieceIndex = (pieceIndex + 1) % 10; // modulo pieces.count
        self.timeLeft += 0.25; // adds to time remaining until gameOver
        self.score += 1;
        self.scoreLabel.string = "\(self.score)";
    }
    
    // detects if character is on the same side as a chopstick, which would make the game be over.
    func isGameOver() -> Bool {
        var newPiece = self.pieces[pieceIndex];
        
        if (newPiece.side == self.character.side) {
            self.triggerGameOver();
        }
        
        return self.gameState == .GameOver;
    }
    
    // puts necessary changes to state in effect when game is over.
    func triggerGameOver() {
        self.gameState = .GameOver;
        //self.restartButton.visible = true; restart button will be visible within gameOverScreen
        
        var gameOverScreen = CCBReader.load("GameOver", owner: self) as! GameOver;
        gameOverScreen.score = score;
        self.addChild(gameOverScreen);
    }
    
    // moves from the title to the actual game
    func start() {
        self.gameState = .Playing;
        self.tapButtons.runAction(CCActionFadeOut(duration: 0.2));
    }
    
    // loads a new piece, runs the correct animation and then loads it to the scene.
    func addHitPiece(obstacleSide: Side) {
        var flyingPiece = CCBReader.load("Piece") as! Piece;
        flyingPiece.position = addPiecesPosition!;
        
        var animationName = (self.character.side == .Left ? "FromLeft" : "FromRight");
        
        flyingPiece.animationManager.runAnimationsForSequenceNamed(animationName);
        flyingPiece.side = obstacleSide;
        
        self.addChild(flyingPiece);
    }
}
