//
//  GameViewModel.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import Foundation
import SwiftUI
import Combine

@Observable
@MainActor
final class GameViewModel {

    var gameState = GameState()
    
    private var undoStack: [GameState] = []
    private var redoStack: [GameState] = []
        
    // MARK: - Save State
    private func saveState() {
        undoStack.append(gameState)
        redoStack.removeAll() // Clear redo when new action happens
    }
        
    private var engine = RulesEngine(
        rules: [
            BallActionRule(),
            StrikeActionRule(),
            SwingAndMissRule(),
            FoulBallRule(),
            SingleAdvanceRule(),
            DoubleAdvanceRule(),
            TripleAdvanceRule(),
            FielderChoiceRule(),
            HitByPitch(),
            IntensionalBallRule(),
            IntentionalWalkRule(),
            CIntenerfaceRule()
        ]
    )
    
    func perform(_ action: GameOption) {
        print("Selected Action:",action.title)
        saveState()
        gameState.gameAction = action
        //let generator = UIImpactFeedbackGenerator(style: .light)
        //generator.impactOccurred()
        withAnimation {
            engine.process(action: action , viewModel: self)
        }
    }
    
    func safeOutPerform(for player: Player, decision: SafeOutDecision) {
        engine.safeOutDecision(for: player, decision: decision, viewModel: self)
    }
    
    func addHomePlayer() {
        gameState.currentOrder = (gameState.currentOrder % gameState.players.count) + 1
        if gameState.currentOrder > gameState.players.count {
            gameState.currentOrder = 1
        }
        if let newPlayer = gameState.players.first(where: { $0.order == gameState.currentOrder }) {
            gameState.basePlayers.append(newPlayer)
        }
    }
    
    func removeHomePlayer() {
        if let index = gameState.basePlayers.firstIndex(where: { $0.base == .scored }) {
            gameState.basePlayers.remove(at: index)
        }
    }
    
    func advancePlayers() {
        for i in gameState.basePlayers.indices.reversed() {
            if gameState.basePlayers[i].base != .scored {
                gameState.basePlayers[i].base.next()
            }
        }
    }
    
    func advancePlayersIfEmpty() {
        
        // Determine current occupancy
        let has1st = gameState.basePlayers.contains { $0.base == .first }
        let has2nd = gameState.basePlayers.contains { $0.base == .second }
        let has3rd = gameState.basePlayers.contains { $0.base == .third }

        var didScore = false
        withAnimation(.spring) {
            
            // If bases loaded → runner on 3rd scores
            if has1st == true && has2nd == true && has3rd == true {
                //if let thirdIndex = viewModel.gameState.basePlayers.firstIndex(where: { $0.base == .third }) {
                self.advancePlayers()
                //}
                return
            }
            
            // Move runners in reverse order (3rd -> 2nd -> 1st)
            
            // Move 2B to 3B if forced
            if has1st == true && has2nd == true {
                //thirdBase = secondBase
                if let thirdIndex = gameState.basePlayers.firstIndex(where: { $0.base == .second }) {
                    didScore = true
                    gameState.basePlayers[thirdIndex].base = .third
                }
                //secondBase = firstBase
                if let thirdIndex = gameState.basePlayers.firstIndex(where: { $0.base == .first }) {
                    gameState.basePlayers[thirdIndex].base = .second
                }
                //firstBase = batter
                if let thirdIndex = gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                    gameState.basePlayers[thirdIndex].base = .first
                }
                return
            }

            
            // Move 1B to 2B if forced
            if has1st == true {
                //secondBase = firstBase
                //firstBase = batter
                if let thirdIndex = gameState.basePlayers.firstIndex(where: { $0.base == .first }) {
                    gameState.basePlayers[thirdIndex].base = .second
                }
                //firstBase = batter
                if let thirdIndex = gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                    gameState.basePlayers[thirdIndex].base = .first
                }
                return
            }
            
            // If first base empty
            //firstBase = batter
            if let homeIndex = gameState.basePlayers.firstIndex(where: { $0.base == .home }) {
                gameState.basePlayers[homeIndex].base = .first
            }
        
        } completion: {
            if didScore {
                self.removeHomePlayer()
            }
            // Bring in the next batter
            self.addHomePlayer()
        }
    }

    
    func changeInning() {
        if gameState.isTopInning {
            gameState.isTopInning = false
        } else {
            gameState.isTopInning = true
            gameState.inning += 1
        }
    }
    
    var isHomePlayerEmpty:Bool {
        return gameState.basePlayers.first(where: { $0.base == .scored }) == nil &&
               gameState.basePlayers.first(where: { $0.base == .home }) == nil
        
    }
    
    func endInning() {
        // TODO: Implement end inning logic (e.g., reset bases, increment inning, switch teams)
        print("End Inning tapped")
    }

    func skip() {
        // TODO: Implement skip logic (e.g., skip to next batter or next play)
        print("Skip tapped")
    }

    func repeatLastAction() {
        // TODO: Implement repeat-last-action logic
        print("Repeat tapped")
    }

    func undo() {
        // TODO: Implement undo logic (maintain history stack of game states)
        print("Undo tapped")
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(gameState)
        withAnimation {
            gameState = previous
        }
    }

    func redo() {
        // TODO: Implement redo logic (maintain history stack of game states)
        print("Redo tapped")
        guard let next = redoStack.popLast() else { return }
        undoStack.append(gameState)
        withAnimation {
            gameState = next
        }
    }
  
}


/*
 @MainActor
 func animate (_ animation: Animation = .spring(),_ body: @escaping () -> Void) async {
     await withCheckedContinuation { continuation in
         withAnimation(animation, completionCriteria: .removed) {
             body()
         } completion: {
             continuation.resume()
         }
     }
 }
 */


