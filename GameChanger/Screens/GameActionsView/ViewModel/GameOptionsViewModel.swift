//
//  GameOptionsViewModel.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 09/03/26.
//

import Foundation
import Combine

@Observable
class GameOptionsViewModel {
    var options =  [GameOption]()
    var errorMessage:String?
    let service: GameOptionsStoreProtocol
    init(service: GameOptionsStoreProtocol) {
        self.service = service
    }
    func getOptions() {
        do {
            options = try service.loadOptions()
        }catch(let error) {
            self.errorMessage = error.localizedDescription
        }
    }
}

