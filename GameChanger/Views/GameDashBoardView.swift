//
//  GameDashBoardView.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import SwiftUI

struct GameDashBoardView: View {
    @StateObject private var viewModel = GameViewModel()
    var body: some View {
        VStack(spacing:0) {
            ScoreCardView(vm: viewModel)
            CustomTabView(vm: viewModel)
        }
    }
}

#Preview {
    GameDashBoardView()
}

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

struct ScoringView: View {
    
    @ObservedObject var vm: GameViewModel
    @State private var showOptions = false
    @State private var selectedOption:GameAction?

    @State private var dragOffsets: [UUID: CGSize] = [:]
    
    
    
    var body: some View {
        //let _ = Self._printChanges()
        GeometryReader { geo in
            
                ZStack {
                    
                    let players = vm.gameState.basePlayers
                    //let homeIndices = players.indices.filter { players[$0].base == .scored }
                    
                    //Player layout
                    ForEach(players.indices, id: \.self) { i in
                        let player = players[i]
                        let homeOffset = getPoint(i: i, player: player, geo: geo)
                        PlayerView(player: player)
                            .position(homeOffset)
                            .zIndex(player.isSafeOutRequired  ? 1 : 0)
                            .offset(dragOffsets[player.id] ?? .zero)
                            .gesture (
                                DragGesture(coordinateSpace: .global)
                                    .onChanged { value in
                                        dragOffsets[player.id] = value.translation
                                    }
                                    .onEnded { value in
                                        withAnimation {
                                            dragOffsets[player.id] = .zero
                                        }
                                    }
                            )
                    }
                    
                    ForEach(players.indices.filter { players[$0].isSafeOutRequired }, id: \.self) { safeOutIndex in
                        Color.black
                            .opacity(0.4)
                            .ignoresSafeArea(.all)
                        let player = players[safeOutIndex]
                        SafeOutView(vm: vm, player: player)
                            .zIndex(1)
                            .position(positionForSafeOut(for: player.base, geo: geo))
                    }
                    
                    optionSelection()
                    .fullScreenCover(isPresented: $showOptions) {
                            GameOptionsView(vm: vm)
                            .presentationBackground(Color.black.opacity(0.3))
                    }
                }
            
        }.onAppear {
            //print("@@@@onAppear@@@@")
            if vm.gameState.basePlayers.isEmpty {
                    self.vm.addHomePlayer()
            }
        }//.coordinateSpace(name: "PlayArea")
    }
    
    
    @ViewBuilder
    func optionSelection() -> some View {
        Button {
            showOptions.toggle()
        }label: {
            Image(systemName: "cricket.ball.circle.fill")
                .font(.largeTitle)
                .fontWeight(.heavy)
        }.zIndex(-1)
    }
    
    func getPoint(i:Int,player:Player,geo:GeometryProxy) -> CGPoint {
        let players = vm.gameState.basePlayers
        let homeIndices = players.indices.filter { players[$0].base == .scored }
        let position = position(for: player.base, geo: geo)
        if  player.base == .scored {
            return CGPoint(x: position.x - CGFloat(homeIndices.firstIndex(of: i)! * 70), y: position.y)
        }
        return position
    }
    
    func position(for base: Base, geo: GeometryProxy) -> CGPoint {
        let center = CGPoint(
            x: geo.size.width / 2,
            y: geo.size.height / 2
        )
        let r = min(geo.size.width, geo.size.height) * 0.31
        switch base {
        case .second:
            return CGPoint(x: center.x, y: center.y - r)
        case .first:
            return CGPoint(x: center.x + r, y: center.y)
        case .home,.scored:
            return CGPoint(x: center.x, y: center.y + r)
        case .third:
            return CGPoint(x: center.x - r, y: center.y)
        }
    }
    
    
    func positionForSafeOut(for base: Base, geo: GeometryProxy) -> CGPoint {
        let point = self.position(for: base, geo: geo)
        switch base {
        case .first,.second,.third:
            return  CGPoint(x: point.x, y: point.y - 58)
        case .home,.scored:
            return CGPoint(x: point.x, y: point.y + 58)
        }
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

