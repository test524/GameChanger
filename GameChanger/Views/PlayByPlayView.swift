//
//  PlayByPlayView.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 26/02/26.
//

import Foundation
import SwiftUI

struct PlayByPlayView: View {
    var body: some View {
        ScrollView {
            VStack {
                GeometryReader { geo in
                    let offset = geo.frame(in: .global).minY
                    Text("Offset: \(offset)")
                }
                .frame(height: 0)
                
                ForEach(0..<50) { i in
                    Text("Row \(i)")
                }
            }
        }
    }
}

#Preview {
    PlayByPlayView()
}
