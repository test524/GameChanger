//
//  ViewHelpers.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 01/03/26.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers


struct ScoreCardView: View {
    @ObservedObject var vm: GameViewModel
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
            .fill(.red)
            .overlay {
                VStack{
                    Text("Balls: \(vm.gameState.balls)")
                    Text("Strikes: \(vm.gameState.strikes)")
                }
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.white)
            }
        }
        .background(Color.red)
        .frame(maxWidth:.infinity,maxHeight: 180)
    }
}


struct CustomTabView: View {

    @State private var selectedTab: Tab = .Score
    @ObservedObject var vm: GameViewModel

    var body: some View {
        VStack(spacing: 0) {
            CustomTabBar(selectedTab: $selectedTab)
            // Content
            Group {
                switch selectedTab {
                case .Score:
                    ScoringView(vm: vm)
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


struct GameOptionsView: View {
    
    @ObservedObject var vm:GameViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing:1) {
                ForEach(GameAction.allCases, id: \.self) { option in
                    HStack {
                        Button(option.rawValue) {
                            dismiss()
                            self.selectedOption(option: option)
                        }
                        Spacer()
                    }.frame(maxWidth:.infinity)
                     .frame(height:50)
                    .padding(.leading,16)
                    .background(Color.gray.opacity(0.2))
                }
            }
        }
        .frame(width: 260)
        .frame(height: CGFloat(GameAction.allCases.count) * 50)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
    
    func selectedOption(option:GameAction) {
        vm.gameState.gameAction = option
        Task{
            try? await Task.sleep(for: .seconds(0.5))
            vm.perform(option)
        }
    }
    
}

struct PlayerView : View {
    let player: Player
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(player.color)
            Text(player.name)
            .clipped()
        }
        .frame(width: 60, height: 60)
    }
}

enum Tab: String, CaseIterable {
    case Score = "Scoring"
    case MyTeam = "MyTeam"
    case Opponent = "Opponent"
    case PlayByPlay = "PlayByPlay"
    case BoxScore = "BoxScore"
}


struct CustomTabBar : View {
    
    @Binding var selectedTab: Tab
    @Namespace private var nameSpace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                VStack(spacing: 0) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    } label: {
                        Text(tab.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(selectedTab == tab ? .blue : .gray)
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
        .background(Color.white)
    }
    
}

struct SafeOutView: View {
    //let onDecision: (SafeOutDecision) -> Void
    @ObservedObject var vm: GameViewModel
    var player:Player
    var body: some View {
        HStack(spacing: 0) {
           Button{
               //onDecision(.safe)
               safeOut(onDecision: .safe)
           } label: {
               Text("Safe")
                   .foregroundStyle(Color.white)
                   .padding(.horizontal,20)
                   .padding(.vertical,10)
                   .background(Color.green)
           }
            Button{
                //onDecision(.out)
                safeOut(onDecision: .out)
            } label: {
                Text("Out")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal,20)
                    .padding(.vertical,10)
                    .background(Color.red)
            }
        }
        //.padding(8)
        //.background(.white)
        .cornerRadius(4)
    }
    
    func safeOut(onDecision: SafeOutDecision) {
        vm.safeOutPerform(for: player, decision: onDecision)
        //resolveSafeOutDecision(for: player, decision: onDecision)
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
            .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                print("@@@@@@onDrop")
                action()
                return true
            }//.zIndex(10)
    }
}
