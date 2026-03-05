//
//  GameOptionsStore.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 05/03/26.
//

import Foundation

final class GameOptionsStore {
    static let shared = GameOptionsStore()
    private(set) var options: [GameOption] = []

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
