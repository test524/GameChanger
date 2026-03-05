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
    func execute(state: GameViewModel)
}

protocol SafeOutDecidable {
    func resolveSafeOutDecision(for player: Player, decision: SafeOutDecision, state: GameViewModel)
}

struct RulesEngine {
    private let rules: [GameRule]
    init(rules: [GameRule]) {
           self.rules = rules
    }
    func process(action: GameOption, state: GameViewModel) {
        for rule in rules {
            if rule.applies(to: action, viewModel: state) {
                 rule.execute(state: state)
            }
        }
    }
    func safeOutDecision(for player: Player, decision: SafeOutDecision, state: GameViewModel, action:GameOption) {
        for rule in rules {
            if rule.applies(to: action, viewModel: state),
               let decidable = rule as? SafeOutDecidable {
                decidable.resolveSafeOutDecision(for: player, decision: decision, state: state)
            }
        }
    }
}

struct SingleAdvanceRule: GameRule, SafeOutDecidable {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "single"
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


struct DoubleAdvanceRule: GameRule, SafeOutDecidable {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "double"
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


struct TripleAdvanceRule: GameRule, SafeOutDecidable {
    
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "triple"
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

struct FielderChoiceRule: GameRule, SafeOutDecidable {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        let key = action.title.lowercased()
        return key == "fielderchoice" || key == "fielder's choice" || key == "fielderschoice"
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
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "ball"
    }
    func execute(state: GameViewModel) {
        state.gameState.balls += 1
        if state.gameState.balls >= 4 {
            
            // Reset count after out
            state.gameState.strikes = 0
            state.gameState.balls = 0
            
            withAnimation(.spring) {
                state.advancePlayers()
            }completion: {
                print("Ball action completed")
                state.removeHomePlayer()
                state.addHomePlayer()
            }
        }
    }
}

struct StrikeActionRule: GameRule {
    
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "called strike"
    }
    
    func execute(state: GameViewModel) {
        
        // 1️⃣ Add strike
        state.gameState.strikes += 1
        
        // 2️⃣ If strike limit reached → Out
        if state.gameState.strikes > 2 {
            
            state.gameState.outs += 1
            
            // Reset count after out
            state.gameState.strikes = 0
            state.gameState.balls = 0
            
            // 3️⃣ If outs limit reached → Change inning
            if state.gameState.outs > 2 {
                
                state.gameState.outs = 0
                
                state.changeInning()
                
            }
        }
    }
    
}

struct SwingAndMissRule: GameRule {
    
    private let maxStrikes = 2
    private let maxOuts = 2
    
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "swing and miss"
    }
    
    func execute(state: GameViewModel) {
        
        // 1️⃣ Add Strike
        state.gameState.strikes += 1
        
        // 2️⃣ If strikeout
        if state.gameState.strikes > maxStrikes {
            
            state.gameState.outs += 1
            
            // Reset count for next batter
            state.gameState.strikes = 0
            state.gameState.balls = 0
            
            // Move batting order
            state.gameState.currentOrder += 1
            
            // 3️⃣ If inning over
            if state.gameState.outs > maxOuts {
                state.gameState.outs = 0
                state.changeInning()
            }
        }
    }
}

struct FoulBallRule: GameRule {
    
    private let maxStrikes = 2
    
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "foul ball"
    }
    
    func execute(state: GameViewModel) {
        
        // Only increase strike if less than 2
        if state.gameState.strikes < maxStrikes {
            state.gameState.strikes += 1
        }
        
        // If already 2 strikes → do nothing
    }
}


struct HitByPitch: GameRule {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        let key = action.title
        return key == "Hit by Pitch" || key == "hbp"
    }
    func execute(state: GameViewModel) {
        // Determine current occupancy
        let has1st = state.gameState.basePlayers.contains { $0.base == .first }
        let has2nd = state.gameState.basePlayers.contains { $0.base == .second }
        let has3rd = state.gameState.basePlayers.contains { $0.base == .third }

        var didScore = false
        withAnimation(.spring) {
            
            // If bases loaded → runner on 3rd scores
            if has1st == true && has2nd == true && has3rd == true {
                //if let thirdIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .third }) {
                state.advancePlayers()
                //}
                return
            }
            
            // Move runners in reverse order (3rd -> 2nd -> 1st)
            
            // Move 2B to 3B if forced
            if has1st == true && has2nd == true {
                //thirdBase = secondBase
                if let thirdIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .second }) {
                    didScore = true
                    state.gameState.basePlayers[thirdIndex].base = .third
                }
                //secondBase = firstBase
                if let thirdIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .first }) {
                    state.gameState.basePlayers[thirdIndex].base = .second
                }
                //firstBase = batter
                if let thirdIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                    state.gameState.basePlayers[thirdIndex].base = .first
                }
                return
            }

            
            // Move 1B to 2B if forced
            if has1st == true {
                //secondBase = firstBase
                //firstBase = batter
                if let thirdIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .first }) {
                    state.gameState.basePlayers[thirdIndex].base = .second
                }
                //firstBase = batter
                if let thirdIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                    state.gameState.basePlayers[thirdIndex].base = .first
                }
                return
            }
            
            // If first base empty
            //firstBase = batter
            if let homeIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                state.gameState.basePlayers[homeIndex].base = .first
            }
            
            /*
            if has1st && has2nd && has3rd {
                // Bases loaded: force advance, runner from 3rd scores
                if let thirdIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .third }) {
                    state.gameState.basePlayers[thirdIndex].base = .scored
                    didScore = true
                }
                if let secondIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .second }) {
                    state.gameState.basePlayers[secondIndex].base = .third
                }
                if let firstIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .first }) {
                    state.gameState.basePlayers[firstIndex].base = .second
                }
                if let homeIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                    state.gameState.basePlayers[homeIndex].base = .first
                }
            } else if has1st && has2nd {
                // Runners on 1st and 2nd: both advance one, batter to 1st
                if let secondIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .second }) {
                    state.gameState.basePlayers[secondIndex].base = .third
                }
                if let firstIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .first }) {
                    state.gameState.basePlayers[firstIndex].base = .second
                }
                if let homeIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                    state.gameState.basePlayers[homeIndex].base = .first
                }
            } else if has1st {
                // Runner on 1st only: advance to 2nd, batter to 1st
                if let firstIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .first }) {
                    state.gameState.basePlayers[firstIndex].base = .second
                }
                if let homeIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                    state.gameState.basePlayers[homeIndex].base = .first
                }
            } else {
                // No runner on 1st: batter to 1st
                if let homeIndex = state.gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                    state.gameState.basePlayers[homeIndex].base = .first
                }
            }*/
        } completion: {
            if didScore {
                state.removeHomePlayer()
            }
            // Bring in the next batter
            state.addHomePlayer()
        }
    }
}

