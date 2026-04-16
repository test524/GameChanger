//
//  BaseAction.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import Foundation
import SwiftUI

protocol GameRule {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool
    func execute(viewModel: GameViewModel)
}

protocol SafeOutDecidable {
    func resolveSafeOutDecision(for player: Player, decision: SafeOutDecision, viewModel: GameViewModel)
}

struct RulesEngine {
    private let rules: [GameRule]
    init(rules: [GameRule]) {
           self.rules = rules
    }
    func process(action: GameOption, viewModel: GameViewModel) {
        for rule in rules {
            if rule.applies(to: action, viewModel: viewModel) {
                 rule.execute(viewModel: viewModel)
            }
        }
    }
    func safeOutDecision(for player: Player, decision: SafeOutDecision, viewModel: GameViewModel) {
        for rule in rules {
            if rule.applies(to: viewModel.gameState.gameAction!, viewModel: viewModel),
               let decidable = rule as? SafeOutDecidable {
                decidable.resolveSafeOutDecision(for: player, decision: decision, viewModel: viewModel)
            }
        }
    }
}
