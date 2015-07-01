import Foundation;



enum Side {
    case Left, Right, None
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
    var gameOver = false;
    
    // keeps track of time left for user to make a move. Must gradually increase the decreasing speed.
    var timeLeft: Float = 5 {
        didSet {
            self.timeLeft = max(min(self.timeLeft, 10), 0); // clamps time between 0 and 10
            self.lifeBar.scaleX = self.timeLeft / Float(10); // sets scaleX of lifeBar as a percentage of time over 10 (height of tower)
        }
    }
    
    // keeps track of score.
    var score = 0;
    
    
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
    
    /** methods **/
    
    
    /* cocos2d methods */
    
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
    
    // executed once restartButton is touched.
    func restart() {
        var scene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(scene)
    }
    
    // executed at every frame, updates time and checks if time has ran out
    override func update(delta: CCTime) {
        if (self.gameOver) { return; };
        self.timeLeft -= Float(delta)
        if (self.timeLeft == 0) { // safe to check for 0 equality after clamping
            self.triggerGameOver();
        }
    }
    
    /* iOS methods */
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        // executed when, after cutting the sushi tree, a chopstick piece touches the player on the same side.
        if (self.isGameOver()) { return; };
        if (touch.locationInWorld().x < (CCDirector.sharedDirector().viewSize().width / 2)) {
            self.character.left();
        } else {
            self.character.right();
        }
        // executed when, after cutting the sushi tree, a chopstick piece touches the player who has just moved to the opposite side.
        if (self.isGameOver()) { return; }; // returns Void, interrupting the method execution.
        self.stepTower();
    }
    
    /* custom methods */
    
    // moves current piece to top of the tower, increments its zIndex by 1, randomizes its chopsticks and moves 'piecesNode' down by the size of a piece.
    func stepTower() {
        var piece = self.pieces[self.pieceIndex];
        var yDiff = piece.contentSize.height * 10;
        
        piece.position = ccpAdd(piece.position, CGPoint(x: 0, y: yDiff));
        
        piece.zOrder = piece.zOrder + 1;
        
        self.pieceLastSide = piece.setObstacle(pieceLastSide);
        
        self.piecesNode.position = ccpSub(self.piecesNode.position,
            CGPoint(x: 0, y: piece.contentSize.height));
        
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
        
        return gameOver;
    }
    
    // puts necessary changes to state in effect when game is over.
    func triggerGameOver() {
        self.gameOver = true;
        self.restartButton.visible = true;
    }
}
