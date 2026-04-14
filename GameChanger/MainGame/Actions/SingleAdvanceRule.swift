//
//  SingleAdvanceRule.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 14/04/26.
//
import Foundation
import SwiftUI

struct SingleAdvanceRule: GameRule, SafeOutDecidable {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "single"
    }
    func execute(viewModel: GameViewModel) {
        withAnimation(.spring) {
            viewModel.advancePlayers()
        }completion: {
            let players = viewModel.gameState.basePlayers
            let homeIndices = players.indices.filter { players[$0].base == .scored }
            if homeIndices.count > 0 {
                viewModel.gameState.basePlayers[homeIndices.first!].isSafeOutRequired = true
            }else{
                withAnimation(.spring) {
                    viewModel.addHomePlayer()
                }
            }
        }
    }
    func resolveSafeOutDecision(for player: Player, decision: SafeOutDecision, viewModel: GameViewModel) {
        // Implement SingleAdvanceRule-specific logic here
        if let index = viewModel.gameState.basePlayers.firstIndex(where: { $0.id == player.id }) {
            if decision == .out {
                viewModel.gameState.basePlayers.remove(at: index)
            } else {
                viewModel.gameState.basePlayers[index].isSafeOutRequired = false
                viewModel.gameState.basePlayers.remove(at: index)
            }
            if viewModel.isHomePlayerEmpty {
                //withAnimation(.spring) {
                viewModel.addHomePlayer()
                //}
            }
        }
    }
}
