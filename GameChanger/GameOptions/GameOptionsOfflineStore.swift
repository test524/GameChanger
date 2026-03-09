//
//  GameOptionsStore.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 05/03/26.
//

import Foundation
import Observation

protocol GameOptionsStoreProtocol {
    func loadOptions() throws -> [GameOption]
}

struct  GameOptionsOfflineStore : GameOptionsStoreProtocol {
    func loadOptions() throws -> [GameOption] {
        guard let url = Bundle.main.url(forResource: "GameOptions", withExtension: "json") else {
            throw URLError(.badServerResponse)
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(GameOptionsJsonModel.self, from: data)
        return decoded.data
    }
}

