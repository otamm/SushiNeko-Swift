import Foundation;

class MainScene: CCNode {
    /* custom variables */
    
    // an array to hold Piece class instances
    var pieces:[Piece] = [];
    
    /* code connections; variables must have 'weak' before being declared because they are only pointing to a reference of the object, not storing the actual data. */
    
    // a reserved space that'll contain Piece objects, displaying them there and positioning relative to the node space.
    weak var piecesNode:CCNode!;
    
    // the character instance for the game session
    weak var character:Character!;
    /** methods **/
    
    
    /* cocos2d methods */
    
    // sets up MainScene, executed first
    func didLoadFromCCB() {
        var pieceYPosition:CGFloat = -30;
        
        // adds 10 pieces to scene
        for i in 0..<10 {
            var piece = CCBReader.load("Piece") as! Piece;
            // position will be relative to 'piecesNode' container.
            piece.position = CGPoint(x:0 ,y:CGFloat(pieceYPosition));
            pieceYPosition += piece.contentSizeInPoints.height;
            self.piecesNode.addChild(piece);
            self.pieces.append(piece);
        }
        
        self.userInteractionEnabled = true;
        
    }
    
    /* iOS methods */
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (touch.locationInWorld().x < (CCDirector.sharedDirector().viewSize().width / 2)) {
            self.character.left();
        } else {
            self.character.right();
        }
    }
}
