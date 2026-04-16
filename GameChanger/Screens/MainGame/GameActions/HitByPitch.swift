//
//  HitByPitch.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 14/04/26.
//
import Foundation
import SwiftUI

struct HitByPitch: GameRule {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        let key = action.title
        return key == "Hit by Pitch" || key == "hbp"
    }
    func execute(viewModel: GameViewModel) {
        viewModel.advancePlayersIfEmpty()
    }
}
