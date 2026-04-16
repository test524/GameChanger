//
//  CIntenerfaceRule.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 14/04/26.
//


struct CIntenerfaceRule : GameRule {
    func applies(to action: GameOption, viewModel: GameViewModel) -> Bool {
        action.title == "C. Interference"
    }
    func execute(viewModel: GameViewModel) {
        viewModel.advancePlayersIfEmpty()
    }
}