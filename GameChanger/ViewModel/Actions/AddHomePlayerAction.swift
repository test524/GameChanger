//
//  AddHomePlayerAction.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import Foundation
import SwiftUI


struct AddHomePlayerAction: GameRule {
    func applies(to action: GameAction, viewModel: GameViewModel) -> Bool {
        action == .single
    }
    func execute(state: GameViewModel) {
        state.gameState.currentOrder += 1
        if state.gameState.players.count == state.gameState.currentOrder {
            state.gameState.currentOrder = 1
        }
        if let newPlayer = state.gameState.players.filter({$0.order == state.gameState.currentOrder}).first {
            state.gameState.basePlayers.append(newPlayer)
        }
    }
}
