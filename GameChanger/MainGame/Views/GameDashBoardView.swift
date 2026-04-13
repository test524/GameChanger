//
//  GameDashBoardView.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import SwiftUI

struct GameDashBoardView: View {
    var body: some View {
        VStack(spacing:0) {
            ScoreCardView()
            CustomTabView()
        }
    }
}

struct ScoringView: View {
    
    //@ObservedObject var vm: GameViewModel
    @Environment(GameViewModel.self) var vm
    
    @State private var dragOffsets: [UUID: CGSize] = [:]
    @State private var hoverPlayerID: UUID?
    @State private var hoverBase: Base?
    
    @State private var showOptions = false
    
    @State private var decisionFrames: [SafeOutDecision: CGRect] = [:]
    
    var body: some View {
        VStack(spacing:0) {
            Rectangle()
                .foregroundStyle(Color.yellow)
                .frame(maxWidth:.infinity)
                .frame(height:40)
            getMainView()
            bottomBar()
        }.ignoresSafeArea()
    }
    
    
    func getMainView() -> some View {
        GeometryReader { geo in
                ZStack {
                    // Bottom layer: field and all non-decision players
                    Image("baseball")
                        .resizable()
                        //.scaledToFill()
                        .zIndex(0)

                    fieldersView(geo: geo)
                        .zIndex(0.5)
                    
                    // Non-decision players
                    playersView(geo: geo)
                        .zIndex(1)

                    // Middle layer: dim overlay when a decision is required
                    if vm.gameState.basePlayers.contains(where: { $0.isSafeOutRequired }) {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .zIndex(2)
                    }

                    // Top layer: only the players that require decision and their SafeOutView
                    decisionLayer(geo: geo)
                        //.zIndex(3)

                    // Controls and decision popup should appear above players if needed
                    optionSelection(geo:geo)
                        .zIndex(1)
                    decisionPopup(geo: geo)
                        .zIndex(5)
                }//.ignoresSafeArea()
                .coordinateSpace(name: "field")
        }//.background(Color.red)
        .onAppear {
            if vm.gameState.basePlayers.isEmpty {
               self.vm.addHomePlayer()
            }
        }
        /*.safeAreaInset(edge: .bottom) {
            bottomBar()
            .offset(y:20)
        }*/
    }
    
    
    func optionSelection(geo:GeometryProxy) -> some View {
        Button {
            showOptions.toggle()
        }label: {
            Image(systemName: "cricket.ball.circle.fill")
                .font(.largeTitle)
                .fontWeight(.heavy)
        }
        .fullScreenCover(isPresented: $showOptions) {
            GameOptionsView(onSelect: {selectedOption in
                vm.perform(selectedOption)
            })
            //.presentationBackground(Color.black.opacity(0.3))
        }.position(pitchBallPosition(geo: geo))
    }
    
}

extension ScoringView {
    
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
    func fieldersView(geo: GeometryProxy) -> some View {
        let all = vm.gameState.players.filter({$0.positionId != 10})
        ForEach(all) { player in
            // Compute position from the player's Position defaultHitPoint
            let pos = Position(player.positionId)
            let hp = pos.defaultHitPoint
            let point = CGPoint(x: hp.x * geo.size.width, y: hp.y * geo.size.height)
            ZStack {
                Circle()
                    .fill(player.color.opacity(0.85))
                    .frame(width: 22, height: 22)
                    .overlay(
                        Text(pos.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.white)
                    )
            }
            .position(point)
        }
    }
}

extension ScoringView {
    @ViewBuilder
    func playersView(geo: GeometryProxy) -> some View {
        let players = vm.gameState.basePlayers
        ForEach(players.filter { !$0.isSafeOutRequired }) { player in
            let i = players.firstIndex(where: { $0.id == player.id }) ?? 0
            PlayerView(player: player)
                .position(self.getPoint(i: i, player: player, geo: geo))
                .offset(dragOffsets[player.id] ?? .zero)
                .gesture(
                    DragGesture(coordinateSpace: .named("field"))
                        .onChanged { value in
                            let start = self.getPoint(i: i, player: player, geo: geo)
                            dragOffsets[player.id] = CGSize(
                                width: value.location.x - start.x,
                                height: value.location.y - start.y
                            )
                            
                            hoverPlayerID = player.id
                            hoverBase = nearestBase(to: value.location, geo: geo)
                        }
                        .onEnded { value in
                            handleDrop(player: player, location: value.location, geo: geo)
                        }
                )
        }
    }
}

extension ScoringView {
    @ViewBuilder
    func decisionLayer(geo: GeometryProxy) -> some View {
        let players = vm.gameState.basePlayers
        // Only render the players requiring a decision on this top layer
        ForEach(players.indices.filter { players[$0].isSafeOutRequired }, id: \.self) { i in
            let player = players[i]
            PlayerView(player: player)
                .position(self.getPoint(i: i, player: player, geo: geo))
                .zIndex(2)
        }
        // And render their SafeOut popups above them
        ForEach(players.indices.filter { players[$0].isSafeOutRequired }, id: \.self) { i in
            let player = players[i]
            SafeOutView(player: player, onDecision: { player, decision in
                vm.safeOutPerform(for: player, decision: decision)
            })
            .position(positionForSafeOut(for: player.base, geo: geo))
            .zIndex(2)
        }
    }
}

extension ScoringView {
    
    func handleDrop(player: Player,
                    location: CGPoint,
                    geo: GeometryProxy) {
        
        let dropPoint = location
        
        // Check popup overlap
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
            var nearest = nearestBase(to: dropPoint, geo: geo)
            // If a runner (not the batter) is dragged to home, treat as scored
            if nearest == .home && player.base != .home {
                nearest = .scored
            }
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
            .zIndex(5)
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
            return CGPoint(x: position.x - CGFloat(homeIndices.firstIndex(of: i)! * 47), y: position.y)
        }
        return position
    }
    
    func pitchBallPosition(geo: GeometryProxy) -> CGPoint {
        let (px,py) = (0.50,0.63)
        return CGPoint(x: px * geo.size.width, y: py * geo.size.height)
    }
    
    func position(for base: Base, geo: GeometryProxy) -> CGPoint {
        // Percentage anchors tuned to the softball background image.
        // Adjust these values if you need to fine-tune alignment.
        let anchors: [Base: (CGFloat, CGFloat)] = [
            .home:   (0.50, 0.82),
            .first:  (0.76, 0.59),
            .second: (0.50, 0.40),
            .third:  (0.24, 0.59),
            .scored: (0.50, 0.82)
        ]
        let (px, py) = anchors[base] ?? (0.50, 0.88)
        return CGPoint(x: px * geo.size.width, y: py * geo.size.height)
    }
    
    func positionForSafeOut(for base: Base, geo: GeometryProxy) -> CGPoint {
        let point = self.position(for: base, geo: geo)
        switch base {
        case .first, .second, .third:
            return CGPoint(x: point.x, y: point.y - 45)
        case .home, .scored:
            return CGPoint(x: point.x, y: point.y + 45)
        }
    }
    
    func nearestBase(to point: CGPoint, geo: GeometryProxy) -> Base {
        let positions: [(Base, CGPoint)] = [
            (.home, position(for: .home, geo: geo)),
            (.first, position(for: .first, geo: geo)),
            (.second, position(for: .second, geo: geo)),
            (.third, position(for: .third, geo: geo)),
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

#Preview {
    GameDashBoardView()
        .environment(GameViewModel())
}

