//
//  BoxScoreView.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 07/03/26.
//

import SwiftUI

struct BoxScoreView: View {

    let rows = 50
    let columns = 20
    let cellWidth: CGFloat = 80
    let cellHeight: CGFloat = 40

    @State private var scrollX: CGFloat = 0
    @State private var scrollY: CGFloat = 0

    var body: some View {

        //ScrollView([.vertical]) {
        ScrollView {
            VStack(spacing: 0) {

                RoundedRectangle(cornerRadius: 0)
                    .foregroundStyle(Color.cyan)
                    .frame(height: 150)
                
                // Top Header
                HStack(spacing: 0) {

                    Color.gray.frame(width: cellWidth, height: cellHeight)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(0..<columns, id: \.self) { col in
                                Text("C\(col)")
                                    .frame(width: cellWidth, height: cellHeight)
                                    .background(Color.gray.opacity(0.3))
                                    .border(Color.gray)
                            }
                        }
                    }
                    .disabled(false)
                }

                HStack(spacing: 0) {

                    // Left Header
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(0..<rows, id: \.self) { row in
                                Text("R\(row)")
                                    .frame(width: cellWidth, height: cellHeight)
                                    .background(Color.gray.opacity(0.3))
                                    .border(Color.gray)
                            }
                        }
                    }
                    .frame(width: cellWidth)
                    .disabled(true)

                    // Main Grid
                    ScrollView([.horizontal,.vertical]) {

                        VStack(spacing: 0) {
                            ForEach(0..<rows, id: \.self) { row in
                                HStack(spacing: 0) {

                                    ForEach(0..<columns, id: \.self) { col in
                                        Text("\(row),\(col)")
                                            .frame(width: cellWidth, height: cellHeight)
                                            .border(Color.gray.opacity(0.5))
                                    }

                                }
                            }
                        }

                    }
                }

                RoundedRectangle(cornerRadius: 0)
                    .foregroundStyle(Color.red)
                    .frame(height: 150)
                
            }
        }
        //}
    }
}

#Preview {
    BoxScoreView()
}

