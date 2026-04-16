//
//  OpponentTeamView.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 25/02/26.
//

import Foundation
import SwiftUI


struct OpponentTeamView: View {
    
    @Environment(GameViewModel.self) var viewModel
    @State private var showPositionPicker: Bool = false
    @State private var selectedPlayerID: UUID? = nil
    
    private var fielders: [Player] {
        viewModel.gameState.players.filter { Position($0.positionId) != .extraHitter }
    }

    private var lineup: [Player] {
        viewModel.gameState.opponent
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(lineup) { player in
                        PlayerRow(player: player) {
                            selectedPlayerID = player.id
                            showPositionPicker = true
                        }
                    }.onMove(perform: move)
                }header: {
                    //SectionHeader(title: "Lineup")
                }
            }
            .contentMargins(.top, 0, for: .scrollContent)
            .listSectionSpacing(0)
            .listStyle(.plain)
            .environment(\.editMode, .constant(.active))
            .sheet(isPresented: $showPositionPicker) {
                PositionPickerView(current: currentPositionForSelected(), onSelect: { newPosition in
                    applyPositionChange(newPosition)
                    showPositionPicker = false
                }, onCancel: {
                    showPositionPicker = false
                })
            }
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
    
    private func currentPositionForSelected() -> Position? {
        guard let id = selectedPlayerID,
              let player = viewModel.gameState.players.first(where: { $0.id == id })
        else { return nil }
        return Position(player.positionId)
    }

    private func applyPositionChange(_ newPosition: Position) {
        guard let id = selectedPlayerID,
              let idx = viewModel.gameState.players.firstIndex(where: { $0.id == id })
        else { return }

        // If another player already has this position, set that player's position to EH
        if let conflictIndex = viewModel.gameState.players.firstIndex(where: { $0.id != id && $0.positionId == newPosition.positionId }) {
            viewModel.gameState.players[conflictIndex].positionId = Position.extraHitter.positionId
        }

        // Now set the selected player's position
        viewModel.gameState.players[idx].positionId = newPosition.positionId
    }
    
}


#Preview {
    OpponentTeamView()
        .environment(GameViewModel())
}
