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













struct StrikeActionRule: GameRule {
    
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "called strike"
    }
    
    func execute(viewModel: GameViewModel) {
        
        // 1️⃣ Add strike
        viewModel.gameState.strikes += 1
        
        // 2️⃣ If strike limit reached → Out
        if viewModel.gameState.strikes > 2 {
            
            viewModel.gameState.outs += 1
            
            // Reset count after out
            viewModel.gameState.strikes = 0
            viewModel.gameState.balls = 0
            
            // 3️⃣ If outs limit reached → Change inning
            if viewModel.gameState.outs > 2 {
                
                viewModel.gameState.outs = 0
                
                viewModel.changeInning()
                
            }
        }
    }
    
}

struct SwingAndMissRule: GameRule {
    
    private let maxStrikes = 2
    private let maxOuts = 2
    
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title == "Swing & Miss"
    }
    
    func execute(viewModel: GameViewModel) {
        
        // 1️⃣ Add Strike
        viewModel.gameState.strikes += 1
        
        // 2️⃣ If strikeout
        if viewModel.gameState.strikes > maxStrikes {
            
            viewModel.gameState.outs += 1
            
            // Reset count for next batter
            viewModel.gameState.strikes = 0
            viewModel.gameState.balls = 0
            
            // Move batting order
            viewModel.gameState.currentOrder += 1
            
            // 3️⃣ If inning over
            if viewModel.gameState.outs > maxOuts {
                viewModel.gameState.outs = 0
                viewModel.changeInning()
            }
        }
    }
}

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


struct HitByPitch: GameRule {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        let key = action.title
        return key == "Hit by Pitch" || key == "hbp"
    }
    func execute(viewModel: GameViewModel) {
        
        viewModel.advancePlayersIfEmpty()
        
        /*
        // Determine current occupancy
        let has1st = viewModel.gameState.basePlayers.contains { $0.base == .first }
        let has2nd = viewModel.gameState.basePlayers.contains { $0.base == .second }
        let has3rd = viewModel.gameState.basePlayers.contains { $0.base == .third }

        var didScore = false
        withAnimation(.spring) {
            
            // If bases loaded → runner on 3rd scores
            if has1st == true && has2nd == true && has3rd == true {
                //if let thirdIndex = viewModel.gameState.basePlayers.firstIndex(where: { $0.base == .third }) {
                viewModel.advancePlayers()
                //}
                return
            }
            
            // Move runners in reverse order (3rd -> 2nd -> 1st)
            
            // Move 2B to 3B if forced
            if has1st == true && has2nd == true {
                //thirdBase = secondBase
                if let thirdIndex = viewModel.gameState.basePlayers.firstIndex(where: { $0.base == .second }) {
                    didScore = true
                    viewModel.gameState.basePlayers[thirdIndex].base = .third
                }
                //secondBase = firstBase
                if let thirdIndex = viewModel.gameState.basePlayers.firstIndex(where: { $0.base == .first }) {
                    viewModel.gameState.basePlayers[thirdIndex].base = .second
                }
                //firstBase = batter
                if let thirdIndex = viewModel.gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                    viewModel.gameState.basePlayers[thirdIndex].base = .first
                }
                return
            }

            
            // Move 1B to 2B if forced
            if has1st == true {
                //secondBase = firstBase
                //firstBase = batter
                if let thirdIndex = viewModel.gameState.basePlayers.firstIndex(where: { $0.base == .first }) {
                    viewModel.gameState.basePlayers[thirdIndex].base = .second
                }
                //firstBase = batter
                if let thirdIndex = viewModel.gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                    viewModel.gameState.basePlayers[thirdIndex].base = .first
                }
                return
            }
            
            // If first base empty
            //firstBase = batter
            if let homeIndex = viewModel.gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                viewModel.gameState.basePlayers[homeIndex].base = .first
            }
        
        } completion: {
            if didScore {
                viewModel.removeHomePlayer()
            }
            // Bring in the next batter
            viewModel.addHomePlayer()
        }
        */
        
    }
}

struct IntensionalBallRule : GameRule {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "Intentional Ball"
    }
    func execute(viewModel: GameViewModel) {
        viewModel.gameState.balls += 1
        if viewModel.gameState.balls >= 4 {
            
            // Reset count after out
            viewModel.gameState.strikes = 0
            viewModel.gameState.balls = 0
            
            withAnimation(.spring) {
                viewModel.advancePlayers()
            }completion: {
                viewModel.removeHomePlayer()
                viewModel.addHomePlayer()
            }
        }
    }
}

struct IntentionalWalkRule : GameRule {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title == "Intentional Walk"
    }
    func execute(viewModel: GameViewModel) {
        viewModel.advancePlayersIfEmpty()
    }
}

struct CIntenerfaceRule : GameRule {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title == "C. Interference"
    }
    func execute(viewModel: GameViewModel) {
        viewModel.advancePlayersIfEmpty()
    }
}



