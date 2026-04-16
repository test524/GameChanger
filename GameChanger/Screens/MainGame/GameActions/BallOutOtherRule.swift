//
//  BallOutOtherRule.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 16/04/26.
//
import Foundation
import SwiftUI

struct BallOutOtherRule : GameRule {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title == "Batter Out: Other"
    }
    
    func execute(viewModel: GameViewModel) {
        // Reset count after out
        viewModel.gameState.strikes = 0
        viewModel.gameState.balls = 0
        viewModel.gameState.outs += 1
        
        if viewModel.gameState.outs == 3 {
            viewModel.changeInning()
        }
        
        //Remove home player
        viewModel.removeHomePlayerForBatterOutOther()
        
        //Add new home player
        viewModel.addHomePlayer()
    }
}
