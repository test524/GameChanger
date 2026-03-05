//
//  OpponentTeamView.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 25/02/26.
//

import Foundation
import SwiftUI


struct OpponentTeamView: View {
    
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.gameState.opponent) { player in
                    //PlayerRow(player: player, onTapPosition: <#() -> Void#>)
                    Text("pl")
                }
                .onMove(perform: move)
            }.listStyle(.plain)
            // 1. Force the list into Edit Mode so reordering is always "ready"
            .environment(\.editMode, .constant(.active))
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        viewModel.gameState.opponent.move(fromOffsets: source, toOffset: destination)
        
        // Optional: Update the 'order' property after the move
        for i in 0..<viewModel.gameState.opponent.count {
            viewModel.gameState.opponent[i].order = i + 1
            print(viewModel.gameState.opponent[i].order)
        }
    }
    
}

#Preview {
    OpponentTeamView()
        .environmentObject(GameViewModel())
}
