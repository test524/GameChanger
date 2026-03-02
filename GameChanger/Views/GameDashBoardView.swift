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

struct ScoringView: View {
    
    @ObservedObject var vm: GameViewModel
    
    @State private var dragOffsets: [UUID: CGSize] = [:]
    @State private var hoverPlayerID: UUID?
    @State private var hoverBase: Base?
    
    @State private var showOptions = false
    
    // popup frames
    @State private var decisionFrames: [SafeOutDecision: CGRect] = [:]
    
    var body: some View {
        GeometryReader { geo in
                ZStack {
                    basesView(geo: geo)
                    playersView(geo: geo)
                    optionSelection()
                    decisionPopup(geo: geo)
                }.coordinateSpace(name: "field")
        }
        .onAppear {
            if vm.gameState.basePlayers.isEmpty {
                    self.vm.addHomePlayer()
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
                .offset(y:20)
        }
        .overlay {
            if vm.gameState.basePlayers.contains(where: { $0.isSafeOutRequired }) {
                Color.black.opacity(0.4).allowsHitTesting(true)
                    .ignoresSafeArea()
            }
        }
    }
    
    @ViewBuilder
    func optionSelection() -> some View {
        Button {
            showOptions.toggle()
        }label: {
            Image(systemName: "cricket.ball.circle.fill")
                .font(.largeTitle)
                .fontWeight(.heavy)
        }//.zIndex(-1)
        .fullScreenCover(isPresented: $showOptions) {
            GameOptionsView(vm: vm)
            .presentationBackground(Color.black.opacity(0.3))
        }
    }
    
}


extension ScoringView {
    @ViewBuilder
    func basesView(geo: GeometryProxy) -> some View {
        Group {
            BaseMarker().position(position(for: .home, geo: geo))
            BaseMarker().position(position(for: .first, geo: geo))
            BaseMarker().position(position(for: .second, geo: geo))
            BaseMarker().position(position(for: .third, geo: geo))
            BaseMarker().position(position(for: .scored, geo: geo))
        }
    }
}

extension ScoringView {
    @ViewBuilder
    func playersView(geo: GeometryProxy) -> some View {
        let players = vm.gameState.basePlayers
        
        Image("baseball")
            .resizable()
            .scaledToFill()

        ForEach(players.indices, id: \.self) { i in
            let player = players[i]
            PlayerView(player: player)
                .position(self.getPoint(i: i, player: player, geo: geo))
                .offset(dragOffsets[player.id] ?? .zero)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffsets[player.id] = value.translation
                            
                            let start = position(for: player.base, geo: geo)
                            let current = CGPoint(
                                x: start.x + value.translation.width,
                                y: start.y + value.translation.height
                            )
                            
                            hoverPlayerID = player.id
                            hoverBase = nearestBase(to: current, geo: geo)
                        }
                        .onEnded { value in
                            handleDrop(player: player, value: value, geo: geo)
                        }
                ).zIndex(hoverPlayerID == player.id ? 2 : 1)
        }
        
        ForEach(players.indices.filter { players[$0].isSafeOutRequired }, id: \.self) {safeOutIndex in
            let player = players[safeOutIndex]
            SafeOutView(vm: vm, player: player)
                .zIndex(3) .position(positionForSafeOut(for: player.base, geo: geo))
        }
        
    }
}

extension ScoringView {
    
    func handleDrop(player: Player,
                    value: DragGesture.Value,
                    geo: GeometryProxy) {
        
        let start = position(for: player.base, geo: geo)
        let dropPoint = CGPoint(
            x: start.x + value.translation.width,
            y: start.y + value.translation.height
        )
    
        // Check popup overlap
        print("safeFrame:", decisionFrames[.safe] ?? .zero)
        print("dropPoint:", dropPoint)
        
        if let safeFrame = decisionFrames[.safe],
           safeFrame.contains(dropPoint) {
            vm.safeOutPerform(for: player, decision: .safe)
        }
        else if let outFrame = decisionFrames[.out],
                outFrame.contains(dropPoint) {
            vm.safeOutPerform(for: player, decision: .out)
        }
        else {
            // normal base move
            let nearest = nearestBase(to: dropPoint, geo: geo)
            if let idx = vm.gameState.basePlayers.firstIndex(where: { $0.id == player.id }) {
                withAnimation {
                    vm.gameState.basePlayers[idx].base = nearest
                }
            }
        }
        
        dragOffsets[player.id] = .zero
        hoverPlayerID = nil
        hoverBase = nil
    }
}

extension ScoringView {
    @ViewBuilder
    func decisionPopup(geo: GeometryProxy) -> some View {
        if  let hoverID = hoverPlayerID,
              let base = hoverBase,
              let player = vm.gameState.basePlayers.first(where: { $0.id == hoverID })
        {
            VStack(spacing: 6) {
                decisionButton(.safe)
                decisionButton(.out)
            }
            .padding(6)
            .background(.thinMaterial)
            .cornerRadius(10)
            .position(position(for: base, geo: geo))
            //.zIndex(10)
        }
    }
    
    func decisionButton(_ decision: SafeOutDecision) -> some View {
        Text(decision == .safe ? "Safe" : "Out")
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 120, height: 50)
            .background(decision == .safe ? Color.green : Color.red)
            .cornerRadius(8)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            decisionFrames[decision] = geo.frame(in: .named("field")) //geo.frame(in: .global)
                        }
                        .onChange(of: geo.frame(in: .named("field")), initial: true) { oldState,newState   in
                            decisionFrames[decision] = newState
                        }
                        /*.onChange(of: geo.frame(in: .named("field"))) { new in
                            decisionFrames[decision] = new
                        }*/
                }
            )
    }
}

extension ScoringView {
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
        print("Width:",geo.size.width)
        print("Height:",geo.size.height)
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
    
    func nearestBase(to point: CGPoint, geo: GeometryProxy) -> Base {
        let positions: [(Base, CGPoint)] = [
            (.home, position(for: .home, geo: geo)),
            (.first, position(for: .first, geo: geo)),
            (.second, position(for: .second, geo: geo)),
            (.third, position(for: .third, geo: geo)),
            (.scored, position(for: .scored, geo: geo))
        ]
        let nearest = positions.min { lhs, rhs in
            let dl = hypot(lhs.1.x - point.x, lhs.1.y - point.y)
            let dr = hypot(rhs.1.x - point.x, rhs.1.y - point.y)
            return dl < dr
        }
        return nearest?.0 ?? .home
    }
}

extension ScoringView {
    @ViewBuilder
    func bottomBar() -> some View {
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
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThickMaterial)
        .disabled(vm.gameState.basePlayers.contains(where: { $0.isSafeOutRequired }))
    }

    @ViewBuilder
    func barButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
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

#Preview {
    GameDashBoardView()
}

