//
//  GameOptionModels.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 05/03/26.
//

import Foundation

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
