//
//  GameOptions.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 04/03/26.
//

import Foundation
import SwiftUI


struct GameOptionsView: View {
    
    @State var vm = GameOptionsViewModel(service: GameOptionsOfflineStore())
    let onSelect: (GameOption) -> Void

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            GameOptionsListView(options: vm.options, onSelect: handleSelection)
            .navigationTitle("Game Options")
        }.task {
            vm.getOptions()
        }.overlay {
            if vm.options.isEmpty == true {
                ProgressView()
            }
        }
    }
    
    private func handleSelection(_ option: GameOption) {
        dismiss()
        Task {
            try? await Task.sleep(for: .seconds(0.2))
            //vm.perform(option)
            onSelect(option)
        }
    }
    
}

struct GameOptionsListView: View {
    
    let options: [GameOption]
    let onSelect: (GameOption) -> Void
    
    
    var body: some View {
        List(options) { option in
            
            if option.children.isEmpty {
                
                // Leaf node → selectable
                Button(option.title) {
                    onSelect(option)
                }
                
            } else {
                
                // Has children → navigate deeper
                NavigationLink(option.title) {
                    GameOptionsListView(
                        options: option.children,
                        onSelect: onSelect
                    )
                    .navigationTitle(option.title)
                }
            }
        }.listStyle(.plain)
        
    }
}

#Preview {
    GameDashBoardView()
}
