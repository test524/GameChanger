//
//  StrikeActionRule.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 14/04/26.
//
import Foundation
import SwiftUI

struct StrikeActionRule: GameRule {
    
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "called strike"
    }
    
    func execute(viewModel: GameViewModel) {
        
        // 1️⃣ Add strike
        viewModel.gameState.strikes += 1
        
        // 2️⃣ If strike limit reached → Out
        if viewModel.gameState.strikes > 2 {
            
            viewModel.gameState.outs += 1
            
            // Reset count after out
            viewModel.gameState.strikes = 0
            viewModel.gameState.balls = 0
            
            // 3️⃣ If outs limit reached → Change inning
            if viewModel.gameState.outs > 2 {
                
                viewModel.gameState.outs = 0
                
                viewModel.changeInning()
                
            }
        }
    }
}
