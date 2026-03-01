//
//  GameViewModel.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import Foundation
import SwiftUI
import Combine


@MainActor
final class GameViewModel : ObservableObject {

    @Published var gameState = GameState()
    
    private var engine = RulesEngine(
        rules: [
            BallActionRule(),
            SingleAdvanceRule(),
            DoubleAdvanceRule(),
            TripleAdvanceRule(),
            FielderChoiceRule()
        ]
    )
    
    func perform(_ action: GameAction) {
        withAnimation {
            engine.process(action: action , state: self)
        }
    }
    
    func safeOutPerform(for player: Player, decision: SafeOutDecision) {
        engine.safeOutDecision(for: player, decision: decision, state: self, action: self.gameState.gameAction!)
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
    
    var isHomePlayerEmpty:Bool {
        return gameState.basePlayers.first(where: { $0.base == .scored }) == nil &&
               gameState.basePlayers.first(where: { $0.base == .home }) == nil
        
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


