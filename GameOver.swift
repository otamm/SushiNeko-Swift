//
//  GameOver.swift
//  SushiNeko
//
//  Created by Otavio Monteagudo on 7/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class GameOver:CCNode {
    weak var restartButton:CCButton!;
    
    weak var scoreLabel: CCLabelTTF!;
    var score: Int = 0 {
        didSet {
            self.scoreLabel.string = "\(score)";
        }
    }
    
    func didLoadFromCCB() {
        self.restartButton.cascadeOpacityEnabled = true;
        self.restartButton.runAction(CCActionFadeIn(duration: 0.3));
    }
}