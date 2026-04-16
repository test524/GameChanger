//
//  FielderChoiceRule.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 14/04/26.
//
import Foundation
import SwiftUI

struct FielderChoiceRule: GameRule, SafeOutDecidable {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        return action.title == "Fielder’s Choice"
    }
    
    func execute(viewModel: GameViewModel) {
        withAnimation(.easeInOut) {
            viewModel.advancePlayers()
        } completion: {
            // Forced out at first: remove player now at first base
            if let firstBaseIndex = viewModel.gameState.basePlayers.firstIndex(where: { $0.base == .first }) {
                viewModel.gameState.basePlayers.remove(at: firstBaseIndex)
            }
            // Mark safe/out needed for second and third base
            for i in viewModel.gameState.basePlayers.indices {
                if viewModel.gameState.basePlayers[i].base == .second || viewModel.gameState.basePlayers[i].base == .third {
                    viewModel.gameState.basePlayers[i].isSafeOutRequired = true
                }
            }
            // After resolving, UI should prompt home base safe/out
            print("Fielder's Choice logic complete; safe/out needed for 2nd and 3rd, then home")
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
            }
        }
        // After resolving, if there are still players (second/third/home) needing a prompt, the UI will show the next one automatically.
        // If all isSafeOutRequired == false, and home player exists, you may want to prompt for home base after second/third as per your scenario.
        let needFurtherPrompt = viewModel.gameState.basePlayers.contains(where: { $0.isSafeOutRequired })
        if !needFurtherPrompt {
            // Optionally, prompt the home base runner
            if let homeIndex = viewModel.gameState.basePlayers.firstIndex(where: { $0.base == .scored }) {
                viewModel.gameState.basePlayers[homeIndex].isSafeOutRequired = true
            }
        }
        // If home is resolved or not present, add a new home player
        if viewModel.isHomePlayerEmpty {
            viewModel.addHomePlayer()
            //for i in gameState.basePlayers.indices {
                //gameState.basePlayers[i].isSafeOutRequired = false
            //}
        }
    }
}
