// SafeOutDecidable.swift
// Protocol for rules/actions that handle Safe/Out decisions

import Foundation

protocol SafeOutDecidable {
    func resolveSafeOutDecision(for player: Player, decision: SafeOutDecision, state: GameViewModel)
}
