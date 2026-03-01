//
//  GameModels.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import Foundation
import SwiftUI


enum Base: Int {
    case home = 0, first, second, third, scored

    mutating func next() {
        // 1. If they have already scored, they don't move anymore.
        if self == .scored { return }
        
        // 2. If they are at third, the next step is scored (they cross home).
        if self == .third {
            self = .scored
            return
        }
        
        // 3. Otherwise, just move to the next numeric base.
        if let nextBase = Base(rawValue: self.rawValue + 1) {
            self = nextBase
        }
    }
}

public extension Color {
    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
}

struct Player: Identifiable, Equatable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
    let id = UUID()
    var base: Base
    let color: Color
    let name : String
    var order : Int
    var isSafeOutRequired : Bool = false
    init(base: Base, color: Color, name:String, order:Int) {
        self.base = base
        self.color = color
        self.name = name
        self.order = order
    }
}


enum GameAction: String, CaseIterable {
    case ball = "Ball"
    case strike = "Strike"
    case single = "Single"
    case double = "Double"
    case triple = "Triple"
    case fielderChoice = "Fielder's Choice"
}


enum SafeOutDecision {
    case safe
    case out
}

/*
enum Base: Int, CaseIterable {
    
    case home = 0
    case first = 1
    case second = 2
    case third = 3
    
    static func > (lhs: Base, rhs: Base) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
    
    static func < (lhs: Base, rhs: Base) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    mutating func next() {
        if let next = Base(rawValue: rawValue + 1) {
            self = next
        }else if self == .third {
            self = .home
        }
    }
    
    var description:String {
        switch self{
        case .third:
            return "Third"
        case .second:
            return "Second"
        case .first:
            return "First"
        case .home:
            return "Home"
        }
    }
    
}
*/
