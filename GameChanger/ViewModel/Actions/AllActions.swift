//
//  BaseAction.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import Foundation
import SwiftUI


protocol GameRule {
    func resolveSafeOutDecision(for player: Player, decision: SafeOutDecision, state: GameViewModel)
    func applies(to action: GameAction, viewModel: GameViewModel) -> Bool
    func execute(state: GameViewModel)
}

struct RulesEngine {
    private let rules: [GameRule]
    init(rules: [GameRule]) {
           self.rules = rules
    }
    func process(action: GameAction, state: GameViewModel) {
        for rule in rules {
            if rule.applies(to: action, viewModel: state) {
                 rule.execute(state: state)
            }
        }
    }
    func safeOutDecision(for player: Player, decision: SafeOutDecision, state: GameViewModel, action:GameAction) {
        for rule in rules {
            if rule.applies(to: action, viewModel: state) {
                rule.resolveSafeOutDecision(for: player, decision: decision, state: state)
            }
        }
    }
}

struct SingleAdvanceRule: GameRule, SafeOutDecidable {
    func applies(to action: GameAction, viewModel: GameViewModel) -> Bool {
        action == .single
    }
    func execute(state: GameViewModel) {
        withAnimation(.spring) {
            state.advancePlayers()
        }completion: {
            let players = state.gameState.basePlayers
            let homeIndices = players.indices.filter { players[$0].base == .scored }
            if homeIndices.count > 0 {
                state.gameState.basePlayers[homeIndices.first!].isSafeOutRequired = true
            }else{
                withAnimation(.spring) {
                    state.addHomePlayer()
                }
            }
        }
    }
    func resolveSafeOutDecision(for player: Player, decision: SafeOutDecision, state: GameViewModel) {
        // Implement SingleAdvanceRule-specific logic here
        if let index = state.gameState.basePlayers.firstIndex(where: { $0.id == player.id }) {
            if decision == .out {
                state.gameState.basePlayers.remove(at: index)
            } else {
                state.gameState.basePlayers[index].isSafeOutRequired = false
                state.gameState.basePlayers.remove(at: index)
            }
            if state.isHomePlayerEmpty {
                //withAnimation(.spring) {
                    state.addHomePlayer()
                //}
            }
        }
    }
}


struct DoubleAdvanceRule: GameRule {
    func applies(to action: GameAction, viewModel: GameViewModel) -> Bool {
        action == .double
    }
    func execute(state: GameViewModel) {
        withAnimation(.spring) {
            state.advancePlayers()
        } completion: {
            withAnimation(.spring) {
                state.advancePlayers()
            }completion: {
                let players = state.gameState.basePlayers
                let homeIndices = players.indices.filter { players[$0].base == .scored }
                if homeIndices.count > 0 {
                    state.gameState.basePlayers[homeIndices.first!].isSafeOutRequired = true
                }else{
                    state.addHomePlayer()
                }
            }
        }
    }
    func resolveSafeOutDecision(for player: Player, decision: SafeOutDecision, state: GameViewModel) {
        if let index = state.gameState.basePlayers.firstIndex(where: { $0.id == player.id }) {
            if decision == .out {
                // Remove the player from base
                state.gameState.basePlayers.remove(at: index)
            } else {
                // Mark as resolved, no longer needs prompt
                state.gameState.basePlayers[index].isSafeOutRequired = false
                state.gameState.basePlayers.remove(at: index)
            }
            let players = state.gameState.basePlayers
            let homeIndices = players.indices.filter { players[$0].base == .scored }
            if homeIndices.count > 0 {
                state.gameState.basePlayers[homeIndices.first!].isSafeOutRequired = true
            }else{
                state.addHomePlayer()
            }
        }
    }
}


struct TripleAdvanceRule: GameRule {
    
    func applies(to action: GameAction, viewModel: GameViewModel) -> Bool {
        action == .triple
    }
    
    func execute(state: GameViewModel) {
        withAnimation(.spring) {
            state.advancePlayers()
        } completion: {
            withAnimation(.spring) {
                state.advancePlayers()
            }completion: {
                withAnimation(.spring) {
                    state.advancePlayers()
                }completion: {
                    let players = state.gameState.basePlayers
                    let homeIndices = players.indices.filter { players[$0].base == .scored }
                    if homeIndices.count > 0 {
                        state.gameState.basePlayers[homeIndices.first!].isSafeOutRequired = true
                    }else{
                        state.addHomePlayer()
                    }
                }
            }
        }
    }
    
    func resolveSafeOutDecision(for player: Player, decision: SafeOutDecision, state: GameViewModel) {
        if let index = state.gameState.basePlayers.firstIndex(where: { $0.id == player.id }) {
            if decision == .out {
                // Remove the player from base
                state.gameState.basePlayers.remove(at: index)
            } else {
                // Mark as resolved, no longer needs prompt
                state.gameState.basePlayers[index].isSafeOutRequired = false
                state.gameState.basePlayers.remove(at: index)
            }
            let players = state.gameState.basePlayers
            let homeIndices = players.indices.filter { players[$0].base == .scored }
            if homeIndices.count > 0 {
                state.gameState.basePlayers[homeIndices.first!].isSafeOutRequired = true
            }else{
                state.addHomePlayer()
            }
        }
    }
    
}

struct FielderChoiceRule: GameRule {
    func applies(to action: GameAction, viewModel: GameViewModel) -> Bool {
        action == .fielderChoice
    }
    func execute(state: GameViewModel) {
        withAnimation(.easeInOut) {
            state.advancePlayers()
        } completion: {
            // Forced out at first: remove player now at first base
            if let firstBaseIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .first }) {
                state.gameState.basePlayers.remove(at: firstBaseIndex)
            }
            // Mark safe/out needed for second and third base
            for i in state.gameState.basePlayers.indices {
                if state.gameState.basePlayers[i].base == .second || state.gameState.basePlayers[i].base == .third {
                    state.gameState.basePlayers[i].isSafeOutRequired = true
                }
            }
            // After resolving, UI should prompt home base safe/out
            print("Fielder's Choice logic complete; safe/out needed for 2nd and 3rd, then home")
        }
    }
    func resolveSafeOutDecision(for player: Player, decision: SafeOutDecision, state: GameViewModel) {
        if let index = state.gameState.basePlayers.firstIndex(where: { $0.id == player.id }) {
            if decision == .out {
                // Remove the player from base
                state.gameState.basePlayers.remove(at: index)
            } else {
                // Mark as resolved, no longer needs prompt
                state.gameState.basePlayers[index].isSafeOutRequired = false
            }
        }
        // After resolving, if there are still players (second/third/home) needing a prompt, the UI will show the next one automatically.
        // If all isSafeOutRequired == false, and home player exists, you may want to prompt for home base after second/third as per your scenario.
        let needFurtherPrompt = state.gameState.basePlayers.contains(where: { $0.isSafeOutRequired })
        if !needFurtherPrompt {
            // Optionally, prompt the home base runner
            if let homeIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .scored }) {
                state.gameState.basePlayers[homeIndex].isSafeOutRequired = true
            }
        }
        // If home is resolved or not present, add a new home player
        if state.isHomePlayerEmpty {
            state.addHomePlayer()
            //for i in gameState.basePlayers.indices {
                //gameState.basePlayers[i].isSafeOutRequired = false
            //}
        }
    }
}

struct BallActionRule: GameRule {
    func applies(to action: GameAction, viewModel: GameViewModel) -> Bool {
        action == .ball
    }
    func execute(state: GameViewModel) {
        state.gameState.balls += 1
        if state.gameState.balls >= 4 {
            state.gameState.clearCount()
            withAnimation(.spring) {
                state.advancePlayers()
            }completion: {
                print("Ball action completed")
                state.removeHomePlayer()
                state.addHomePlayer()
            }
        }
    }
    func resolveSafeOutDecision(for player: Player, decision: SafeOutDecision, state: GameViewModel) {
        
    }
}

