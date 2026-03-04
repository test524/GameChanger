//
//  GameModels.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import Foundation
import SwiftUI
import Combine

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

struct GameOptionsJsonModel : Decodable {
    let data:[GameOption]
}

struct GameOption: Decodable, Identifiable {
    let id: Int
    let title: String
    let children: [GameOption]
    //let actionKey: String

    enum CodingKeys: String, CodingKey { case id, title, children}

    init(id: Int, title: String,children:[GameOption]) {
        self.id = id
        self.title = title
        self.children = children
        //self.actionKey = actionKey
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.title = try c.decode(String.self, forKey: .title)
        self.children = try c.decode([GameOption].self, forKey: .children)
        //self.actionKey = try c.decode(String.self, forKey: .actionKey)
    }
}


final class GameOptionsStore {
    static let shared = GameOptionsStore()
    private(set) var options: [GameOption] = []
    private var loaded = false

    private init() {
        load()
    }

    func load() {
        guard let url = Bundle.main.url(forResource: "GameOptions", withExtension: "json") else {
            options = []
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try loadJSONData(from: data)
            self.options = decoded
        } catch {
            print("Failed to load GameOptions.json:", error)
            self.options = []
        }
    }
    
    func loadJSONData(from data: Data) throws -> [GameOption] {
        try JSONDecoder().decode(GameOptionsJsonModel.self, from: data).data
    }
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

