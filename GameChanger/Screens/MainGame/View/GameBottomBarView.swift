//
//  GameBottomBarOptionsView.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 16/04/26.
//

import SwiftUI
import Combine

struct GameBottomBarView: View {
    
    var vm: GameViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            barButton(icon: "flag.checkered", title: "End") { vm.endInning() }
            Spacer()
            barButton(icon: "forward.end.fill", title: "Skip") { vm.skip() }
            barButton(icon: "repeat", title: "Repeat") { vm.repeatLastAction() }
            barButton(icon: "repeat", title: "Repeat") { vm.repeatLastAction() }
            Spacer()
            barButton(icon: "arrow.uturn.left", title: "Undo") { vm.undo() }
            barButton(icon: "arrow.uturn.right", title: "Redo") { vm.redo() }
        }
        .frame(maxWidth:.infinity)
        .frame(height:60)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThickMaterial)
        .zIndex(6)
        .disabled(vm.gameState.basePlayers.contains(where: { $0.isSafeOutRequired }))
        .offset(y:-15)
    }
    
    @ViewBuilder
    func barButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.orange))
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
        }
    }
}


