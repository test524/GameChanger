//
//  GameState.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import Foundation
import SwiftUI


struct GameState {
    
    var balls: Int = 0
    var strikes: Int = 0
    var outs: Int = 0
    var inning: Int = 1
    var isTopInning: Bool = true
    var currentOrder = 0
    var gameAction:GameAction? = nil
    
    var players: [Player] = [
        Player(base: .home, color: Color.red ,name: "Name:1M", order: 1),
        Player(base: .home, color: Color.blue ,name: "Name:2M", order: 2),
        Player(base: .home, color: Color.green ,name: "Name:3M", order: 3),
        Player(base: .home, color: Color.orange,name: "Name:4M", order: 4),
        Player(base: .home, color: Color.pink ,name: "Name:5M", order: 5),
        Player(base: .home, color: Color.purple ,name: "Name:6M", order: 6),
        Player(base: .home, color: Color.black.opacity(0.5) ,name: "Name:7M", order: 7),
        Player(base: .home, color: Color.brown ,name: "Name:8M", order: 8),
        Player(base: .home, color: Color.cyan ,name: "Name:9M", order: 9)
    ]
    
    var opponent: [Player] = [
        Player(base: .home, color: Color.red ,name: "Name:1OP", order: 1),
        Player(base: .home, color: Color.blue ,name: "Name:2OP", order: 2),
        Player(base: .home, color: Color.green ,name: "Name:3OP", order: 3),
        Player(base: .home, color: Color.orange,name: "Name:4OP", order: 4),
        Player(base: .home, color: Color.pink ,name: "Name:5OP", order: 5),
        Player(base: .home, color: Color.purple ,name: "Name:6OP", order: 6),
        Player(base: .home, color: Color.black.opacity(0.5) ,name: "Name:OP", order: 7),
        Player(base: .home, color: Color.brown ,name: "Name:8OP", order: 8),
        Player(base: .home, color: Color.cyan ,name: "Name:9OP", order: 9)
    ]
    
    var basePlayers = [Player]()
    
    // Add logic to check if the state needs resetting
    mutating func clearCount() {
        balls = 0
        strikes = 0
    }
    
}
