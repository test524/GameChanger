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

    var body: some View {
        VStack{
            AppHeader {
                Text("Game Screen")
                    .font(.title)
                    .foregroundColor(.white)
            }
            Spacer()
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
        .environment(GameViewModel())
}


struct AppHeader<Content: View>: View {
    
    let height: CGFloat
    let backgroundColor: Color
    let content: Content
    
    init(
        height: CGFloat = 80,
        backgroundColor: Color = .blue,
        @ViewBuilder content: () -> Content
    ) {
        self.height = height
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            backgroundColor
                .ignoresSafeArea(edges: .top)
            
            content
                .padding(.bottom, 20)
        }
        .frame(height: height)
    }
}
