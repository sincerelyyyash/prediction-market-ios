//
//  HomeView.swift
//  Pulse
//
//  Created by Yash Thakur on 26/11/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                Color.black
                    .ignoresSafeArea()
                
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: .white, location: 0.0),
                        .init(color: Color(red: 0.7, green: 0.7, blue: 0.75), location: 0.35),
                        .init(color: .black, location: 0.7)
                    ]),
                    center: .top,
                    startRadius: 0,
                    endRadius: 600
                )
                .frame(height: geo.size.height * 0.5)
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)
                
            }
        }
    }
}

#Preview {
    HomeView()
}
