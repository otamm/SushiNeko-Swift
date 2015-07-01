//
//  Piece.swift
//  SushiNeko
//
//  Created by Otavio Monteagudo on 7/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Piece:CCNode {
    
    /* code connections */
    // left chopstick of a piece
    weak var leftChopstick: CCSprite!;
    
    // right chopstick of a piece, never to be alongside a left one (or vice-versa)
    weak var rightChopstick: CCSprite!;
    
    /* custom variables */
    
    // side of the chopstick in the current piece; there should never be two chopsticks at once.
    var side: Side = .None {
        // didSet block is called each time 'side' is set; will set the other chopstick visibility to 'false' (two chopsticks are created for each Piece instance, only the visible triggers a 'game over'
        didSet {
            self.leftChopstick.visible = false;
            self.rightChopstick.visible = false;
            if self.side == .Right {
                self.rightChopstick.visible = true;
            } else if self.side == .Left {
                self.leftChopstick.visible = true;
            }
        }
    }
    
    /*** methods ***/
    
    /* custom methods */
    
    // will set obstacle side for this Piece instance.
    func setObstacle(lastSide: Side) -> Side {
        if (lastSide != .None) {
            self.side = .None;
        } else {
            var rand = CCRANDOM_0_1()
            if rand < 0.45 {
                self.side = .Left;
            } else if rand < 0.9 {
                self.side = .Right;
            } else {
                self.side = .None;
            }
        }
        return self.side;
    }
    
    
}
