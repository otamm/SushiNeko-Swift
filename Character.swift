//
//  Character.swift
//  SushiNeko
//
//  Created by Otavio Monteagudo on 7/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Character:CCSprite {
    /* variables */
    
    // tracks character side on screen.
    var side:Side = .Left;
    
    /*** methods ***/
    
    /* cocos2d methods */
    
    // move character left
    func left() {
        // scaleX sets the position of the sprite in relation to its anchor point. The character's anchor point is (1,0) inside a square which has a width with half the screen size, so the anchor point is centered in the screen center. Scaling the character's "x" position by -1, it would be placed in the opposite field of where it originally is, having the anchor point as an origin reference.
        self.side = .Left;
        self.scaleX = 1;
    }
    
    // move character right
    func right() {
        
        self.side = .Right;
        self.scaleX = -1;
    }
    
    /* custom methods */
    
    func tap() {
        self.animationManager.runAnimationsForSequenceNamed("Tap");
    }
}
