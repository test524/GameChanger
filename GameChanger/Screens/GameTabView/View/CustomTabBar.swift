//
//  CustomTabBar.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 16/04/26.
//
import SwiftUI

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
