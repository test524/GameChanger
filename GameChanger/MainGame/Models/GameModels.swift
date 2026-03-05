//
//  GameModels.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import Foundation
import SwiftUI
import Combine


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

