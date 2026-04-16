//
//  DoubleAdvanceRule.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 14/04/26.
//
import Foundation
import SwiftUI

struct DoubleAdvanceRule: GameRule, SafeOutDecidable {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title == "Double"
    }
    func execute(viewModel: GameViewModel) {
        withAnimation(.spring) {
            viewModel.advancePlayers()
        } completion: {
            withAnimation(.spring) {
                viewModel.advancePlayers()
            }completion: {
                let players = viewModel.gameState.basePlayers
                let homeIndices = players.indices.filter { players[$0].base == .scored }
                if homeIndices.count > 0 {
                    viewModel.gameState.basePlayers[homeIndices.first!].isSafeOutRequired = true
                }else{
                    viewModel.addHomePlayer()
                }
            }
        }
    }
    func resolveSafeOutDecision(for player: Player, decision: SafeOutDecision, viewModel: GameViewModel) {
        if let index = viewModel.gameState.basePlayers.firstIndex(where: { $0.id == player.id }) {
            if decision == .out {
                // Remove the player from base
                viewModel.gameState.basePlayers.remove(at: index)
            } else {
                // Mark as resolved, no longer needs prompt
                viewModel.gameState.basePlayers[index].isSafeOutRequired = false
                viewModel.gameState.basePlayers.remove(at: index)
            }
            let players = viewModel.gameState.basePlayers
            let homeIndices = players.indices.filter { players[$0].base == .scored }
            if homeIndices.count > 0 {
                viewModel.gameState.basePlayers[homeIndices.first!].isSafeOutRequired = true
            }else{
                viewModel.addHomePlayer()
            }
        }
    }
}
