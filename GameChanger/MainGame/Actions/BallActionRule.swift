//
//  BallActionRule.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 14/04/26.
//
import Foundation
import SwiftUI

struct BallActionRule: GameRule {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "ball"
    }
    func execute(viewModel: GameViewModel) {
        viewModel.gameState.balls += 1
        if viewModel.gameState.balls >= 4 {
            
            // Reset count after out
            viewModel.gameState.strikes = 0
            viewModel.gameState.balls = 0
            
            withAnimation(.spring) {
                viewModel.advancePlayers()
            }completion: {
                print("Ball action completed")
                viewModel.removeHomePlayer()
                viewModel.addHomePlayer()
            }
        }
    }
}
