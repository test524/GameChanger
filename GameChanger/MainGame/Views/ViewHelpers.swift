//
//  ViewHelpers.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 01/03/26.
//

import SwiftUI
import Foundation



struct CustomTabView: View {

    @State private var selectedTab: Tab = .Score
    @EnvironmentObject var vm: GameViewModel

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
                    LoginView()
                case .BoxScore:
                    Text("Box Score").font(.largeTitle)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environmentObject(vm)
        }//.background(.yellow)
        
    }
}


struct PlayerView : View {
    let player: Player
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
            .fill(player.color)
            Text(String(player.order))
            .clipped()
        }
        .frame(width: 42, height: 42)
    }
}


struct CustomTabBar : View {
    
    @Binding var selectedTab: Tab
    @Namespace private var nameSpace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                VStack(spacing: 0) {
                    Button {
                        withAnimation(.spring) {
                            selectedTab = tab
                        }
                    } label: {
                        Text(tab.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(selectedTab == tab ? .orange : .gray)
                            .frame(maxWidth: .infinity, minHeight: 45)
                    }
                    if selectedTab == tab {
                        Capsule()
                            .fill(Color.red)
                            .frame(height: 2)
                            .matchedGeometryEffect(id: "TAB", in: nameSpace)
                    } else {
                        Capsule()
                            .fill(Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color.gray.opacity(0.2))
    }
    
}

struct SafeOutView: View {
    
    let player: Player
    let onDecision: (Player, SafeOutDecision) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            
            Button {
                //withAnimation {
                    onDecision(player, .safe)
                //}
            } label: {
                Text("Safe")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 40)
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 5,
                            bottomLeadingRadius: 5
                        )
                        .fill(Color.green)
                    )
            }
            .buttonStyle(.plain)
            
            
            Button {
                //withAnimation {
                    onDecision(player, .out)
                //}
            } label: {
                Text("Out")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 40)
                    .background(
                        UnevenRoundedRectangle(
                            bottomTrailingRadius: 5, topTrailingRadius: 5
                        )
                        .fill(Color.red)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

struct BaseMarker: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
            .foregroundColor(Color.gray.opacity(0.5))
            .frame(width: 64, height: 64)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.clear)
            )
    }
}

struct DecisionDropView: View {
    let decision: SafeOutDecision
    let action: () -> Void

    var body: some View {
        Text(decision == .safe ? "Safe" : "Out")
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 100, height: 100)
            .background(decision == .safe ? Color.green : Color.red)
            .cornerRadius(8)
    }
}

