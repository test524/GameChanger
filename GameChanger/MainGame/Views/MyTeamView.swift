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
    @State private var showPositionPicker: Bool = false
    @State private var selectedPlayerID: UUID? = nil
    
    private var fielders: [Player] {
        viewModel.gameState.players.filter { Position($0.positionId) != .extraHitter }
    }

    private var lineup: [Player] {
        viewModel.gameState.players
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("No Data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth:.infinity,alignment: .center)
                }header: {
                    SectionHeader(title: "Current Assigned Players")
                }
                Section {
                    ForEach(lineup) { player in
                        PlayerRow(player: player) {
                            selectedPlayerID = player.id
                            showPositionPicker = true
                        }
                    }.onMove(perform: move)
                }header: {
                    SectionHeader(title: "Lineup")
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

struct PlayerRow: View {
    let player: Player
    var onTapPosition: () -> Void
    var body: some View {
        HStack {
            Circle()
                .fill(player.color)
                .frame(width: 15, height: 15)
            Text(player.name)
                .font(.system(.body, design: .monospaced))
            Spacer()
            Button {
                onTapPosition()
            } label: {
                Text(Position(player.positionId).rawValue)
                    .font(.system(.body, design: .monospaced))
            }.padding(.trailing,30)
        }
        .padding(.vertical, 4)
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .frame(maxWidth:.infinity,alignment: .leading)
                .padding(.leading,10)
                .font(.headline)
                .foregroundStyle(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(Color.gray)
                        .frame(height:38)
                )
            Spacer()
        }
    }
}

struct PositionPickerView: View {
    let current: Position?
    let onSelect: (Position) -> Void
    let onCancel: () -> Void
    var body: some View {
        NavigationStack {
            List(Position.allCases, id: \.self) { pos in
                HStack {
                    Text(pos.rawValue)
                    Spacer()
                    if pos == current { Image(systemName: "checkmark") }
                }
                .contentShape(Rectangle())
                .onTapGesture { onSelect(pos) }
            }
            .navigationTitle("Select Position")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
            }
        }
    }
}


#Preview {
    MyTeamView()
        .environmentObject(GameViewModel())
}

