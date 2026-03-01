//
//  MyTeamView.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 25/02/26.
//

import Foundation
import SwiftUI


struct MyTeamView: View {
    
    @EnvironmentObject var viewModel: GameViewModel
    @State var userID:Int = 1
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.gameState.players) { player in
                    PlayerRow(player: player)
                }
                .onMove(perform: move)
            }.listStyle(.plain)
                .task(id: userID) {
                    print("MyTeamView loaded")
                }
            // 1. Force the list into Edit Mode so reordering is always "ready"
            .environment(\.editMode, .constant(.active))
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        viewModel.gameState.players.move(fromOffsets: source, toOffset: destination)
        
        // Optional: Update the 'order' property after the move
        for i in 0..<viewModel.gameState.players.count {
            viewModel.gameState.players[i].order = i + 1
            print(viewModel.gameState.players[i].order)
        }
    }
    
}

struct PlayerRow: View {
    let player: Player
    var body: some View {
        HStack {
            Circle()
                .fill(player.color)
                .frame(width: 15, height: 15)
            Text(player.name)
                .font(.system(.body, design: .monospaced))
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MyTeamView()
        .environmentObject(GameViewModel())
}
