//
//  IntentionalWalkRule.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 14/04/26.
//
import Foundation
import SwiftUI

struct IntentionalWalkRule : GameRule {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title == "Intentional Walk"
    }
    func execute(viewModel: GameViewModel) {
        viewModel.advancePlayersIfEmpty()
    }
}
