//
//  Enums.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 05/03/26.
//

import Foundation


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

enum SafeOutDecision {
    case safe
    case out
}


enum Tab: String, CaseIterable {
    case Score = "Scoring"
    case MyTeam = "MyTeam"
    case Opponent = "Opponent"
    case PlayByPlay = "PlayByPlay"
    case BoxScore = "BoxScore"
}
