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
    var positionId:Int
    init(base: Base, color: Color, name:String, order:Int, positionId:Int = 10) {
        self.base = base
        self.color = color
        self.name = name
        self.order = order
        self.positionId = positionId
    }
}

