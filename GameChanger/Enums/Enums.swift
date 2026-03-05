//
//  Enums.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 05/03/26.
//

import Foundation
import SwiftUI

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

extension Position {
    init(_ positionId: Int) {
        switch positionId {
        case 1: self = .pitcher
        case 2: self = .catcher
        case 3: self = .firstBase
        case 4: self = .secondBase
        case 5: self = .thirdBase
        case 6: self = .shortstop
        case 7: self = .leftField
        case 8: self = .centerField
        case 9: self = .rightField
        case 10: self = .extraHitter
        default: self = .extraHitter
        }
    }
}


enum Position: String,Codable , CaseIterable{
    case pitcher = "P"
    case catcher = "C"
    case firstBase = "1B"
    case secondBase = "2B"
    case thirdBase = "3B"
    case shortstop = "SS"
    case leftField = "LF"
    case centerField = "CF"
    case rightField = "RF"
    case extraHitter = "EH"

    var positionId: Int {
        switch self {
        case .pitcher: return 1
        case .catcher: return 2
        case .firstBase: return 3
        case .secondBase: return 4
        case .thirdBase: return 5
        case .shortstop: return 6
        case .leftField: return 7
        case .centerField: return 8
        case .rightField: return 9
        case .extraHitter: return 10
        }
    }
    
    var defaultHitPoint: HitPoint {
        switch self {
        case .extraHitter: return HitPoint(x: 0.5, y: 0.6739)
            
        case .pitcher: return HitPoint(x: 0.5, y: 0.62)
        case .catcher: return HitPoint(x: 0.50, y: 1.0)
            
        case .firstBase: return HitPoint(x: 0.81, y: 0.59)
        case .thirdBase: return HitPoint(x: 0.19, y: 0.59)
            
        case .secondBase: return HitPoint(x: 0.69, y: 0.50)
        case .shortstop: return HitPoint(x: 0.31, y: 0.50)
            
        case .leftField: return HitPoint(x: 0.15, y: 0.25)
        case .centerField: return HitPoint(x: 0.50, y: 0.18)
        case .rightField: return HitPoint(x: 0.85, y: 0.25)
        }
    }
    
}

struct HitPoint :Codable{
    let x: CGFloat
    let y: CGFloat
}

#Preview {
    GameDashBoardView()
        .environmentObject(GameViewModel())
}
