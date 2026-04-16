//
//  CustomTabView.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 16/04/26.
//
import SwiftUI

struct CustomTabView: View {

    @State private var selectedTab: Tab = .Score
    //@Environment var vm: GameViewModel
    @Environment(GameViewModel.self) var viewModel

    var body: some View {
        VStack(spacing: 0) {
            CustomTabBar(selectedTab: $selectedTab)
            Group {
                switch selectedTab {
                case .Score:
                    ScoringView()
                case .MyTeam:
                    MyTeamView()
                case .Opponent:
                    OpponentTeamView()
                case .PlayByPlay:
                    PlayByPlayView()
                case .BoxScore:
                    BoxScoreView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(viewModel)
        }//.background(.yellow)
        
    }
}
