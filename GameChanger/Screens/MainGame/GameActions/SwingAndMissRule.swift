//
//  SwingAndMissRule.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 14/04/26.
//
import Foundation
import SwiftUI

struct SwingAndMissRule: GameRule {
    
    private let maxStrikes = 2
    private let maxOuts = 2
    
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title == "Swing & Miss"
    }
    
    func execute(viewModel: GameViewModel) {
        
        // 1️⃣ Add Strike
        viewModel.gameState.strikes += 1
        
        // 2️⃣ If strikeout
        if viewModel.gameState.strikes > maxStrikes {
            
            viewModel.gameState.outs += 1
            
            // Reset count for next batter
            viewModel.gameState.strikes = 0
            viewModel.gameState.balls = 0
            
            // Move batting order
            viewModel.gameState.currentOrder += 1
            
            // 3️⃣ If inning over
            if viewModel.gameState.outs > maxOuts {
                viewModel.gameState.outs = 0
                viewModel.changeInning()
            }
        }
    }
}
