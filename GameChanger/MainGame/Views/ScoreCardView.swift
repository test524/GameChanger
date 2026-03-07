//
//  ScoreCardView.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 04/03/26.
//

import SwiftUI

struct ScoreCardView: View {
    
    @Environment(GameViewModel.self) var vm
    
    var body: some View {
        VStack {
            VStack(spacing:4) {
                inningsInfo()
                playerInfo()
                GameCountView(balls: vm.gameState.balls ,
                              strikes: vm.gameState.strikes ,
                              outs: vm.gameState.outs)
                gameInfo()
            }.padding()
        }
        .frame(maxWidth:.infinity)
        .frame(height:170)
    }
    
    func inningsInfo() -> some View {
        
        ZStack {
            Text("Top 6th")
                .font(.system(size: 24, weight: .bold))
            HStack{
                Button{
                    print("back")
                }label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                            .font(.system(size: 16, weight: .bold))
                    }.foregroundStyle(.black)
                }
                Spacer()
                HStack{
                    HStack{
                        Image(systemName: "livephoto.play")
                        Text("LIVE")
                            .font(.system(size: 16, weight: .bold))
                    }
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                }
            }
        }
    }
    
    func playerInfo() -> some View {
        HStack {
            HStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 26,height: 26)
                Spacer()
                Text("Pavan R")
                    .font(Font.system(size: 20, weight: .bold))
                Text("2")
                    .font(Font.system(size: 20, weight: .bold))
            }
            Spacer()
            ThreeDiamondLayout()
            Spacer()
            HStack {
                Text("2")
                    .font(Font.system(size: 20, weight: .bold))
                Text("Amar R")
                    .font(Font.system(size: 20, weight: .bold))
                Spacer()
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 26,height: 26)
            }
        }
    }
    
    func gameInfo() -> some View {
        HStack {
            GameInfo(title: "P", player: "01", info: "Pitches:0")
            Spacer()
            GameInfo(title: "AB", player: "01", info: "0-0")
            Spacer()
            GameInfo(title: "OD", player: "01", info: "0-0")
        }
        .padding(.horizontal,20)
    }
    
}

#Preview {
    ScoreCardView()
        .environment(GameViewModel())
}

struct GameInfo : View {
    let title: String
    let player: String
    let info: String
    var body: some View {
        HStack(spacing:12) {
            Text(title)
                .font(.system(size: 27, weight: .bold))
            VStack(spacing:0) {
                Text(player)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
                Text(info)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
            }
        }
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let top = CGPoint(x: rect.midX, y: rect.minY)
        let right = CGPoint(x: rect.maxX, y: rect.midY)
        let bottom = CGPoint(x: rect.midX, y: rect.maxY)
        let left = CGPoint(x: rect.minX, y: rect.midY)
        
        path.move(to: top)
        path.addLine(to: right)
        path.addLine(to: bottom)
        path.addLine(to: left)
        path.closeSubpath()
        
        return path
    }
}


struct ThreeDiamondLayout: View {
    
    var body: some View {
        ZStack {
            // Top Diamond
            Diamond()
                .fill(Color.blue)
                .frame(width: 18, height: 18)
                .offset(y: -12)
            
            // Left Diamond
            Diamond()
                .fill(Color.green)
                .frame(width: 18, height: 18)
                .offset(x: -10)
            
            // Right Diamond
            Diamond()
                .fill(Color.yellow)
                .frame(width: 18, height: 18)
                .offset(x: 10)
        }
        .frame(width: 50, height: 50)
    }
}

struct CountIndicatorRow: View {
    
    let title: String
    let current: Int
    let max: Int
    let activeColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.caption.bold())
            HStack(spacing:5){
                ForEach(0..<max, id: \.self) { index in
                    Circle()
                        .fill(index < current ? activeColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}

struct GameCountView: View {
    
    var balls: Int
    var strikes: Int
    var outs: Int
    
    var body: some View {
        HStack(spacing: 12) {
            CountIndicatorRow(
                title: "BALL",
                current: balls,
                max: 3,
                activeColor: .green
            ).padding(.leading,30)
            Spacer()
            CountIndicatorRow(
                title: "STRIKE",
                current: strikes,
                max: 2,
                activeColor: .orange
            )
            Spacer()
            CountIndicatorRow(
                title: "OUT",
                current: outs,
                max: 2,
                activeColor: .red
            ).padding(.trailing,30)
        }.padding(.bottom,5)
    }
}


