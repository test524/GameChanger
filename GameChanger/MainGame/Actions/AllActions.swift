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

protocol PlayByPlayProtocol {
    func createPlayByPlayMessage(viewModel: GameViewModel)
}

struct RulesEngine {
    private let rules: [GameRule]
    init(rules: [GameRule]) {
           self.rules = rules
    }
    func process(action: GameOption, viewModel: GameViewModel) {
        //Message
        for rule in rules {
            if rule.applies(to: action, viewModel: viewModel),
               let playByPlay = rule as? PlayByPlayProtocol {
                playByPlay.createPlayByPlayMessage(viewModel: viewModel)
            }
        }
        //Action
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

struct SingleAdvanceRule: GameRule, SafeOutDecidable, PlayByPlayProtocol {
        
    func createPlayByPlayMessage(viewModel: GameViewModel) {
        
        let gameState = viewModel.gameState
        
        guard let batter = gameState.basePlayers.first(where: {$0.base == .home}) else {return}
        var message = batter.name
        message += " singles"

        //Fielder
        /*if let field = event.field {
            message += " to \(field.rawValue)"
        }*/

        message += "."
        
        var movements: [BaseMovement] = []

        // Runner on 3rd scores
        if let runner = gameState.basePlayers.first(where: {$0.base == .third}) {
            movements.append(
                BaseMovement(player: runner, from: .third, to: nil, scored: true)
            )
        }

        // Runner on 2nd scores
        if let runner = gameState.basePlayers.first(where: {$0.base == .second}) {
            movements.append(
                BaseMovement(player: runner, from: .second, to: nil, scored: false)
            )
        }

        // Runner on 1st to 2nd
        if let runner = gameState.basePlayers.first(where: {$0.base == .first}) {
            movements.append(
                BaseMovement(player: runner, from: .first, to: .second, scored: false)
            )
        }

        // Batter to 1st
        movements.append(
            BaseMovement(player: batter, from: .home, to: .first, scored: false)
        )
        
        if !movements.isEmpty {
            let runnerText = movements.map { move -> String in
                if move.scored {
                    return "\(move.player.name) scores"
                }
                if let to = move.to {
                    return "\(move.player.name) advances to \(to.rawValue)"
                }
                return ""
            }
            message += " " + runnerText.joined(separator: ", ") + "."
        }
        
        print("######")
        print(message)
        print("######")
                
    }
    
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


struct DoubleAdvanceRule: GameRule, SafeOutDecidable {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "double"
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


struct TripleAdvanceRule: GameRule, SafeOutDecidable {
    
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "triple"
    }
    
    func execute(viewModel: GameViewModel) {
        withAnimation(.spring) {
            viewModel.advancePlayers()
        } completion: {
            withAnimation(.spring) {
                viewModel.advancePlayers()
            }completion: {
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

struct FielderChoiceRule: GameRule, SafeOutDecidable {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        let key = action.title
        return key == "Fielder’s Choice"
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

struct BallActionRule: GameRule {

    private let maxBalls = 4

    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title.lowercased() == "ball"
    }

    func execute(viewModel: GameViewModel) {
        viewModel.gameState.balls += 1

        guard viewModel.gameState.balls >= maxBalls else {
            return
        }

        viewModel.gameState.strikes = 0
        viewModel.gameState.balls = 0
        viewModel.advancePlayersIfEmpty()
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


