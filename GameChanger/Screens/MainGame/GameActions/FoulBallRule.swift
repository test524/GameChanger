//
//  FoulBallRule.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 14/04/26.
//
import Foundation
import SwiftUI

struct FoulBallRule: GameRule{
    private let maxStrikes = 2
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "foul ball"
    }
    func execute(viewModel: GameViewModel) {
        // Only increase strike if less than 2
        if viewModel.gameState.strikes < maxStrikes {
            viewModel.gameState.strikes += 1
        }
        // If already 2 strikes → do nothing
    }
}
