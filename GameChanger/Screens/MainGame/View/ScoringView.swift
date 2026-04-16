//
//  GameDashBoardView.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import SwiftUI

struct GamePlayView: View {
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
            //Rectangle()
                Text(vm.gameState.gameAction?.title ?? "Scoring")
                .foregroundStyle(Color.black)
                .font(.system(size: 13, weight: .semibold))
                .frame(maxWidth:.infinity)
                .frame(height:40)
            gamePlayView()
            GameBottomBarView(vm: vm)
        }.ignoresSafeArea()
    }
    
    func gamePlayView() -> some View {
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
                }
                .coordinateSpace(name: "field")
        }//.background(Color.red)
        .onAppear {
            if vm.gameState.basePlayers.isEmpty {
               self.vm.addHomePlayer()
            }
        }
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
    
    @ViewBuilder
    func fieldersView(geo: GeometryProxy) -> some View {
        ForEach(Position.allCases, id: \.self) { pos in
            let hp = pos.defaultHitPoint
            let point = CGPoint(x: hp.x * geo.size.width, y: hp.y * geo.size.height)
            let matchingPlayer = vm.gameState.players.first { Position($0.positionId) == pos && pos != .extraHitter}
            ZStack {
                if let player = matchingPlayer {
                    Text(player.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(6)
                        .background(Capsule().fill(player.color.opacity(0.85)))
                        .foregroundStyle(.white)
                } else if pos != .extraHitter {
                    Circle()
                        .fill(Color.red.opacity(0.85))
                        .frame(width: 22, height: 22)
                        .overlay(
                            Text(pos.rawValue)
                                .font(.caption2)
                                .foregroundStyle(.white)
                        )
                }
            }
            .position(point)
        }
    }
    
    @ViewBuilder
    func playersView(geo: GeometryProxy) -> some View {
        let players = vm.gameState.basePlayers
        ForEach(players.indices.filter { !players[$0].isSafeOutRequired }, id: \.self) { i in
            let player = players[i]
            PlayerView(player: player)
                .position(self.getPoint(i: i, player: player, geo: geo))
                .offset(dragOffsets[player.id] ?? .zero)
        }
    }
    
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

#Preview {
    GamePlayView()
        .environment(GameViewModel())
}

